#!/bin/env python

import discord
from discord.ext import commands
import aiohttp
from bs4 import BeautifulSoup
from translate import Translator
import json
import re
from fuzzywuzzy import process
from unidecode import unidecode
from youtubesearchpython import VideosSearch
import asyncio
import pandas as pd

tspdt_rankings = pd.read_excel('/home/emre/.local/bin/tspdt_rankings.xlsx')

def normalize_text(text):
    return unidecode(str(text).lower().replace(' ', '-'))

def get_rotten_tomatoes_urls(movie_name, year):
    movie_name_without_spaces = unidecode(str(movie_name).lower().replace('-', '_'))
    return [f'https://www.rottentomatoes.com/m/{movie_name_without_spaces}',
            f'https://www.rottentomatoes.com/m/{movie_name_without_spaces}_{year}']

async def fetch_text(url, session):
    async with session.get(url) as response:
        return await response.text()

async def get_rotten_tomatoes_audience_score(movie_name, year, session):
    movie_name_without_spaces = unidecode(str(movie_name).lower().replace('-', '_'))
    if normalize_text(movie_name) == 'mirror':
        return '91'

    urls = get_rotten_tomatoes_urls(movie_name, year)

    async def fetch_score(url):
        text = await fetch_text(url, session)
        soup = BeautifulSoup(text, 'html.parser')
        script = soup.find('script', {'id': 'scoreDetails'})
        if script:
            data = json.loads(script.string)
            value = data['scoreboard']['audienceScore'].get('value')
            if value and value != 0:
                return str(value).split('/')[0]
        return None

    scores = await asyncio.gather(*(fetch_score(url) for url in urls))
    return next((score for score in scores if score is not None), "N/A")

async def get_tspdt_ranking(movie_name):
    best_match = process.extractOne(movie_name, tspdt_rankings['title'])[0]
    rank = tspdt_rankings[tspdt_rankings['title'] == best_match]['rank'].values[0]
    return rank

async def get_letterboxd_rating(movie_name, year, session):
    movie_name_with_year = normalize_text(movie_name)
    movie_name_with_year = movie_name.lower().replace(' ', '-')
    if year:
        movie_name_with_year += f'-{year}'
    url_with_year = f'https://letterboxd.com/film/{movie_name_with_year}/'
    async with session.get(url_with_year) as response:
        if response.status != 200:
            movie_name_without_year = movie_name.lower().replace(' ', '-')
            url_without_year = f'https://letterboxd.com/film/{movie_name_without_year}/'
            async with session.get(url_without_year) as response2:
                text = await response2.text()
        else:
            text = await response.text()
    soup = BeautifulSoup(text, 'html.parser')
    meta_tag = soup.find('meta', attrs={'name': 'twitter:data2'})
    if meta_tag:
        rating_text = meta_tag['content']
        rating_out_of_5 = float(rating_text.split(' ')[0])
        return rating_out_of_5 * 2
    else:
        return "N/A"

async def get_metacritic_user_score(movie_name, year, session):
    movie_name_with_dashes = normalize_text(movie_name)
    url_with_year = f"https://www.metacritic.com/movie/{movie_name_with_dashes}-{year}" if year else None
    url_without_year = f"https://www.metacritic.com/movie/{movie_name_with_dashes}"

    headers = {
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36',
        'Referer': 'https://www.metacritic.com'
    }

    if url_with_year:
        async with session.get(url_with_year, headers=headers) as response:
            if response.status == 200:
                text = await response.text()
            else:
                text = None

    if not text:
        async with session.get(url_without_year, headers=headers) as response2:
            text = await response2.text()

    soup = BeautifulSoup(text, 'html.parser')
    score_span = soup.find('span', class_=lambda x: x and "metascore_w" in x and "user" in x and "larger" in x and "movie" in x)
    if score_span:
        score = int(float(score_span.text) * 10)
        return score
    else:
        return None

def get_youtube_trailer_link(movie_name, year):
    search_query = f'{movie_name} {year} trailer'
    video_search = VideosSearch(search_query, limit=1)
    results = video_search.result()
    most_viewed_video_url = results['result'][0]['link'] if results['result'] else None
    return most_viewed_video_url

async def search_torrents(ctx, movie_name, year, session):
    query = f"{movie_name} x265 bluray 1080p 10bit {year}" if year else f"{movie_name} x265"
    query = query.replace(' ', '+')
    search_url = f'https://1337x.to/search/{query}/1/'
    async with session.get(search_url) as response:
        search_page = await response.text()
    movie_matches = re.findall(r"torrent/[0-9]{7}/[a-zA-Z0-9?%-]*/", search_page)
    hash_codes = []
    sizes_in_gb = []
    for movie_match in movie_matches[:5]:
        movie_url = f"https://1337x.to/{movie_match}"
        async with session.get(movie_url) as response:
            movie_page = await response.text()
        hash_match = re.search(r"<strong>Infohash :</strong> <span>([a-zA-Z0-9]*)</span>", movie_page)
        size_match = re.search(r"\b\d+(\.\d+)?\sGB\b", movie_page)
        if hash_match:
            hash_codes.append(hash_match.group(1))
        if size_match:
            sizes_in_gb.append(size_match.group(0))
    if not hash_codes:
        await ctx.send(f"No hash codes found for {movie_name}")
        return
    embed = discord.Embed(title=f"Torrents for {movie_name}", color=discord.Color.blue())
    for index, (hash_code, size_in_gb) in enumerate(zip(hash_codes, sizes_in_gb)):
        hash_title = f"Hash {index + 1} - {size_in_gb}"
        embed.add_field(name=hash_title, value=hash_code, inline=False)
    await ctx.send(embed=embed)

intents = discord.Intents.default()
intents.members = True
intents.message_content = True
bot = commands.Bot(command_prefix='!', intents=intents)

async def main():
    session = aiohttp.ClientSession()

    @bot.command()
    async def m(ctx, *, movie_name):
        normalized_movie_name = normalize_text(movie_name)
        url = "http://www.omdbapi.com/?apikey=98e54415&t=" + normalized_movie_name.replace(' ', '+')
        async with session.get(url) as response:
            data = await response.json()
        if data['Response'] == 'False':
            await ctx.send(f"Movie {movie_name} not found.")
            return
        else:
            year = None
        if data['Response'] == 'True':
            year = data['Year'].split('–')[0]
        rotten_tomatoes_audience = await get_rotten_tomatoes_audience_score(normalized_movie_name, year=year, session=session)
        metacritic_user = await get_metacritic_user_score(normalized_movie_name, year=year, session=session)
        letterboxd_rating = await get_letterboxd_rating(normalized_movie_name, year=year, session=session)
        plot = data['Plot']
        my_email = 'akyuzemr3@gmail.com'
        translator = Translator(to_lang="tr", from_lang="en", email=my_email)
        translated_plot = translator.translate(plot)

        title = data['Title']
        year = data['Year'].split('-')[0]
        genre = data['Genre']
        director = data['Director']
        actors = data['Actors']
        imdb_rating = str(int(float(data['imdbRating']) * 10))
        imdb_votes = data['imdbVotes']
        rotten_tomatoes = 'N/A'
        for rating in data['Ratings']:
            if rating['Source'] == 'Rotten Tomatoes':
                rotten_tomatoes = rating['Value'].replace('%', '')

        metacritic = 'N/A'
        for rating in data['Ratings']:
            if rating['Source'] == 'Metacritic':
                metacritic = rating['Value'].split('/')[0]

        letterboxd_rating_out_of_100 = str(round(float(letterboxd_rating) * 10)) if letterboxd_rating != "N/A" else "N/A"
        tspdt_rank = await get_tspdt_ranking(normalized_movie_name)
        youtube_trailer_link = get_youtube_trailer_link(title, year)

        scores = [
            int(imdb_rating) if imdb_rating is not None else None,
            int(rotten_tomatoes.split('/')[0]) if rotten_tomatoes != "N/A" and '/' in rotten_tomatoes else None,
            int(rotten_tomatoes_audience) if rotten_tomatoes_audience is not None and rotten_tomatoes_audience != "N/A" else None,
            int(metacritic) if metacritic is not None and metacritic != "N/A" else None,
            int(letterboxd_rating_out_of_100) if letterboxd_rating_out_of_100 is not None and letterboxd_rating_out_of_100 != "N/A" else None,
            int(metacritic_user) if metacritic_user is not None and metacritic_user != "N/A" else None
        ]

        valid_scores = [score for score in scores if score is not None]
        average_score = round(sum(valid_scores) / len(valid_scores)) if valid_scores else "N/A"

        embed = discord.Embed(title=title, url=youtube_trailer_link, description=translated_plot, color=discord.Color.blue())
        embed.add_field(name="Year", value=year, inline=True)
        embed.add_field(name="Genre", value=genre, inline=True)
        embed.add_field(name="Director", value=director, inline=True)
        embed.add_field(name="Actors", value=actors, inline=True)
        embed.add_field(name="IMDB", value=imdb_rating, inline=True)
        embed.add_field(name="IMDB Votes", value=imdb_votes, inline=True)
        embed.add_field(name="Rotten", value=rotten_tomatoes, inline=True)
        embed.add_field(name="Rotten Audience", value=rotten_tomatoes_audience, inline=True)
        embed.add_field(name="Metacritic", value=metacritic, inline=True)
        embed.add_field(name="Letterboxd", value=letterboxd_rating_out_of_100, inline=True)
        embed.add_field(name="Metacritic User", value=metacritic_user, inline=True)
        embed.add_field(name="Average Score", value=f"{average_score:.0f}" if average_score != "N/A" else "N/A", inline=True)
        embed.add_field(name="Critic & Director Rank", value=tspdt_rank, inline=True)
        embed.set_thumbnail(url=data['Poster'])

        await ctx.send(embed=embed)
        await ctx.message.delete()

    @bot.command()
    async def t(ctx, *, movie_name):
        normalized_movie_name = normalize_text(movie_name)
        url = "http://www.omdbapi.com/?apikey=98e54415&t=" + normalized_movie_name.replace(' ', '+')
        async with session.get(url) as response:
            data = await response.json()
        if data['Response'] == 'True':
            year = data['Year'].split('–')[0]
        await search_torrents(ctx, movie_name=movie_name, year=year, session=session)
        await ctx.message.delete()

    await bot.start('MTEzNjQyMDEyMTg0NjQ5MzI5NA.G_-78B.YPWfrN1keJieq0m-h2EYSEUFhUdFp4-TDZMse0')

asyncio.run(main())
