#!/bin/env python

import discord
from discord.ext import commands
import requests
from bs4 import BeautifulSoup
import asyncio

intents = discord.Intents.default()
bot = commands.Bot(command_prefix='!', intents=intents)

cache = {
    'last_line': ''
}

async def check_earthquakes():
    url = "http://www.koeri.boun.edu.tr/scripts/lst0.asp"
    response = requests.get(url)

    soup = BeautifulSoup(response.text, "html.parser")
    pre_text = soup.pre.text

    lines = pre_text.split('\n')
    start = next(i for i, line in enumerate(lines) if line.startswith("----------")) + 1
    data_lines = lines[start:]

    data_lines = [line for line in data_lines if len(line.split()) >= 9]
    line = data_lines[0].split()
    date = line[0]
    time = line[1]
    if ":" in time:
        time = time.split(":")[0] + ":" + time.split(":")[1]
    magnitude = line[6]
    location = ' '.join(line[8:-1])
    location = location.split("-")[-1]
    formatted_line = ' | '.join([date, time, magnitude, location])
    if formatted_line != cache.get('last_line'):
        cache['last_line'] = formatted_line
        return formatted_line

@bot.event
async def on_ready():
    print(f'We have logged in as {bot.user}')
    channel = bot.get_channel(<bot-channel-id>)
    while True:
        try:
            msg = await check_earthquakes()
            if msg:
                await channel.send(msg)
        except Exception as e:
            print(f'Error while checking earthquakes: {e}')
        await asyncio.sleep(60)

@bot.command()
async def earthquake(ctx):
    msg = await check_earthquakes()
    if msg:
        await ctx.send(msg)

bot.run('<discord-bot-token>')
