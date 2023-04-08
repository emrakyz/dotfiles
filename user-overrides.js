# My Original Settings #
user_pref("privacy.resistFingerprinting.letterboxing", false);
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("full-screen-api.ignore-widgets", true);
user_pref("geo.enabled", false);
user_pref("media.peerconnection.enabled", false);
user_pref("media.peerconnection.ice.default_address_only", true);
user_pref("browser.tabs.tabmanager.enabled", false);
user_pref("browser.uidensity", 1);
user_pref("extensions.unifiedExtensions.enabled", true);
user_pref("ui.prefersReducedMotion", 1);
user_pref("dom.ipc.processCount", 16);
user_pref("security.ssl.enable_ocsp_stapling", false);
user_pref("security.OCSP.enabled", 0);
user_pref("security.OCSP.require", false);
# Third Party Images (0-1-2)#
user_pref("network.http.referer.XOriginPolicy", 0);
# Location Bar Search #
user_pref("keyword.enabled", true);
user_pref("browser.toolbars.bookmarks.visibility", never);


## Later Added ##
// Release notes and vendor URLs
user_pref("app.releaseNotesURL", "http://127.0.0.1/");
user_pref("app.vendorURL", "http://127.0.0.1/");
user_pref("app.privacyURL", "http://127.0.0.1/");

//Speeding it up
user_pref("network.http.pipelining", true);
user_pref("network.http.proxy.pipelining", true);
user_pref("network.http.pipelining.maxrequests", 10);
user_pref("nglayout.initialpaint.delay", 0);

// Disable default browser checking.
user_pref("browser.shell.checkDefaultBrowser", false);

// Prevent EULA dialog to popup on first run
user_pref("browser.EULA.override", true);

// Don't disable extensions dropped in to a system
// location, or those owned by the application
user_pref("extensions.autoDisableScopes", 3);

// Don't call home for blacklisting
user_pref("extensions.blocklist.enabled", false);

// disable app updater url
user_pref("app.update.url", "http://127.0.0.1/");

user_pref("startup.homepage_welcome_url", "");
user_pref("browser.startup.homepage_override.mstone", "ignore");

// Help URL
user_pref ("app.support.baseURL", "http://127.0.0.1/");
user_pref ("app.support.inputURL", "http://127.0.0.1/");
user_pref ("app.feedback.baseURL", "http://127.0.0.1/");
user_pref ("browser.uitour.url", "http://127.0.0.1/");
user_pref ("browser.uitour.themeOrigin", "http://127.0.0.1/");
user_pref ("plugins.update.url", "http://127.0.0.1/");
user_pref ("browser.customizemode.tip0.learnMoreUrl", "http://127.0.0.1/");

// Dictionary download user_preference
user_pref("browser.dictionaries.download.url", "http://127.0.0.1/");
user_pref("browser.search.searchEnginesURL", "http://127.0.0.1/");
user_pref("layout.spellcheckDefault", 0);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);

// Apturl user_preferences
user_pref("network.protocol-handler.app.apt","/usr/bin/apturl");
user_pref("network.protocol-handler.warn-external.apt",false);
user_pref("network.protocol-handler.app.apt+http","/usr/bin/apturl");
user_pref("network.protocol-handler.warn-external.apt+http",false);
user_pref("network.protocol-handler.external.apt",true);
user_pref("network.protocol-handler.external.apt+http",true);

// Quality of life stuff
user_pref("browser.aboutConfig.showWarning", false);
user_pref("browser.toolbars.bookmarks.visibility", "never");
user_pref("browser.tabs.firefox-view", false);
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Privacy & Freedom Issues
// https://webdevelopmentaid.wordpress.com/2013/10/21/customize-privacy-settings-in-mozilla-firefox-part-1-aboutconfig/
// https://panopticlick.eff.org
// http://ip-check.info
// http://browserspy.dk
// https://wiki.mozilla.org/Fingerprinting
// http://www.browserleaks.com
// http://fingerprint.pet-portal.eu
user_pref("browser.translation.engine", "");
user_pref("media.gmp-provider.enabled", false);
user_pref("browser.urlbar.update2.engineAliasRefresh", true);
user_pref("browser.newtabpage.activity-stream.feeds.topsites", false);
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features", false);
user_pref("browser.urlbar.suggest.engines", false);
user_pref("browser.urlbar.suggest.topsites", false);
user_pref("browser.discovery.containers.enabled", false);
user_pref("browser.discovery.enabled", false);
user_pref("browser.discovery.sites", "http://127.0.0.1/")
user_pref("services.sync.prefs.sync.browser.startup.homepage", false);
user_pref("browser.contentblocking.report.monitor.home_page_url", "http://127.0.0.1/")
user_pref("dom.ipc.plugins.flash.subprocess.crashreporter.enabled", false);
user_pref("browser.safebrowsing.enabled", false);
user_pref("browser.safebrowsing.downloads.remote.enabled", false);
user_pref("browser.safebrowsing.malware.enabled", false);
user_pref("browser.safebrowsing.provider.google.updateURL", "");
user_pref("browser.safebrowsing.provider.google.gethashURL", "");
user_pref("browser.safebrowsing.provider.google4.updateURL", "");
user_pref("browser.safebrowsing.provider.google4.gethashURL", "");
user_pref("browser.safebrowsing.provider.mozilla.gethashURL", "");
user_pref("browser.safebrowsing.provider.mozilla.updateURL", "");
user_pref("services.sync.privacyURL", "http://127.0.0.1/");
user_pref("social.enabled", false);
user_pref("social.remote-install.enabled", false);
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("datareporting.healthreport.about.reportUrl", "http://127.0.0.1/");
user_pref("datareporting.healthreport.documentServerURI", "http://127.0.0.1/");
user_pref("healthreport.uploadEnabled", false);
user_pref("social.toast-notifications.enabled", false);
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("datareporting.healthreport.service.enabled", false);
user_pref("browser.slowStartup.notificationDisabled", true);
user_pref("network.http.sendRefererHeader", 2);
user_pref("network.http.referer.spoofSource", true);
user_pref("dom.event.clipboardevents.enabled",false);
user_pref("network.user_prefetch-next", false);
user_pref("network.dns.disablePrefetch", true);
user_pref("network.http.sendSecureXSiteReferrer", false);
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.server", "");
user_pref("experiments.manifest.uri", "");
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.updatePing.enabled", false);
user_pref("plugins.enumerable_names", "");
user_pref("plugin.state.flash", 0);
user_pref("browser.search.update", false);
user_pref("dom.battery.enabled", false);
user_pref("device.sensors.enabled", false);
user_pref("camera.control.face_detection.enabled", false);
user_pref("camera.control.autofocus_moving_callback.enabled", false);
user_pref("network.http.speculative-parallel-limit", 0);
user_pref("browser.urlbar.userMadeSearchSuggestionsChoice", true);
user_pref("browser.search.suggest.enabled", false);
user_pref("security.certerrors.mitm.priming.enabled", false);
user_pref("security.certerrors.recordEventTelemetry", false);
user_pref("extensions.shield-recipe-client.enabled", false);
user_pref("browser.newtabpage.directory.source", "");
user_pref("browser.newtabpage.directory.ping", "");
user_pref("browser.newtabpage.introShown", true);
user_pref("geo.wifi.uri", "");
user_pref("browser.search.geoip.url", "");
user_pref("browser.search.geoSpecificDefaults", false);
user_pref("browser.search.geoSpecificDefaults.url", "");
user_pref("browser.search.modernConfig", false);
user_pref("captivedetect.canonicalURL", "");
user_pref("network.captive-portal-service.enabled", false);
user_pref("extensions.shield-recipe-client.enabled", false);

// Services
user_pref("gecko.handlerService.schemes.mailto.0.name", "");
user_pref("gecko.handlerService.schemes.mailto.1.name", "");
user_pref("handlerService.schemes.mailto.1.uriTemplate", "");
user_pref("gecko.handlerService.schemes.mailto.0.uriTemplate", "");
user_pref("browser.contentHandlers.types.0.title", "");
user_pref("browser.contentHandlers.types.0.uri", "");
user_pref("browser.contentHandlers.types.1.title", "");
user_pref("browser.contentHandlers.types.1.uri", "");
user_pref("gecko.handlerService.schemes.webcal.0.name", "");
user_pref("gecko.handlerService.schemes.webcal.0.uriTemplate", "");
user_pref("gecko.handlerService.schemes.irc.0.name", "");
user_pref("gecko.handlerService.schemes.irc.0.uriTemplate", "");

// EME
user_pref("media.eme.enabled", false);
user_pref("media.eme.apiVisible", false);

// Firefox Accounts
user_pref("identity.fxaccounts.enabled", false);

// WebRTC
user_pref("media.peerconnection.enabled", false);
// Don't reveal your internal IP when WebRTC is enabled
user_pref("media.peerconnection.ice.no_host", true);
user_pref("media.peerconnection.ice.default_address_only", true);

// Services
user_pref("gecko.handlerService.schemes.mailto.0.name", "");
user_pref("gecko.handlerService.schemes.mailto.1.name", "");
user_pref("handlerService.schemes.mailto.1.uriTemplate", "");
user_pref("gecko.handlerService.schemes.mailto.0.uriTemplate", "");
user_pref("browser.contentHandlers.types.0.title", "");
user_pref("browser.contentHandlers.types.0.uri", "");
user_pref("browser.contentHandlers.types.1.title", "");
user_pref("browser.contentHandlers.types.1.uri", "");
user_pref("gecko.handlerService.schemes.webcal.0.name", "");
user_pref("gecko.handlerService.schemes.webcal.0.uriTemplate", "");
user_pref("gecko.handlerService.schemes.irc.0.name", "");
user_pref("gecko.handlerService.schemes.irc.0.uriTemplate", "");

// https://kiwiirc.com/client/irc.247cdn.net/?nick=Your%20Nickname#underwater-hockey
// Don't call home for blacklisting
user_pref("extensions.blocklist.enabled", false);

// FIXME: find better URLs for these:
user_pref ("extensions.getAddons.langpacks.url", "http://127.0.0.1/");
user_pref ("lightweightThemes.getMoreURL", "http://127.0.0.1/");
user_pref ("browser.geolocation.warning.infoURL", "");
user_pref ("browser.xr.warning.infoURL", "");
user_pref ("app.feedback.baseURL", "");

// Mobile
user_pref("privacy.announcements.enabled", false);
user_pref("browser.snippets.enabled", false);
user_pref("browser.snippets.syncPromo.enabled", false);
user_pref("identity.mobilepromo.android", "http://127.0.0.1/");
user_pref("browser.snippets.geoUrl", "http://127.0.0.1/");
user_pref("browser.snippets.updateUrl", "http://127.0.0.1/");
user_pref("browser.snippets.statsUrl", "http://127.0.0.1/");
user_pref("datareporting.policy.firstRunTime", 0);
user_pref("datareporting.policy.dataSubmissionPolicyVersion", 2);
user_pref("browser.webapps.checkForUpdates", 0);
user_pref("browser.webapps.updateCheckUrl", "http://127.0.0.1/");
user_pref("app.faqURL", "http://127.0.0.1/");

// PFS url
user_pref("pfs.datasource.url", "http://127.0.0.1/");
user_pref("pfs.filehint.url", "http://127.0.0.1/");

// Disable Gecko media plugins: https://wiki.mozilla.org/GeckoMediaPlugins
user_pref("media.gmp-manager.url.override", "data:text/plain,");
user_pref("media.gmp-manager.url", "");
user_pref("media.gmp-manager.updateEnabled", false);
user_pref("media.gmp-provider.enabled", false);
// Don't install openh264 codec
user_pref("media.gmp-gmpopenh264.enabled", false);
user_pref("media.gmp-eme-adobe.enabled", false);

//Disable middle click content load
//Avoid loading urls by mistake
user_pref("middlemouse.contentLoadURL", false);

//Disable heartbeat
user_pref("browser.selfsupport.url", "");

//Disable Link to FireFox Marketplace, currently loaded with non-free "apps"
user_pref("browser.apps.URL", "");

//Disable Firefox Hello
user_pref("loop.enabled",false);

// Disable home snippets
user_pref("browser.aboutHomeSnippets.updateUrl", "");

// In <about:user_preferences>, hide "More from Mozilla"
// (renamed to "More from GNU" by the global renaming)
user_pref("browser.user_preferences.moreFromMozilla", false);

// Disable hardware acceleration
//user_pref("layers.acceleration.disabled", false);
user_pref("gfx.direct2d.disabled", true);

// Disable SSDP
user_pref("browser.casting.enabled", false);

//Disable directory service
user_pref("social.directories", "");

// Don't report TLS errors to Mozilla
user_pref("security.ssl.errorReporting.enabled", false);

// disable screenshots extension
user_pref("extensions.screenshots.disabled", true);
// disable onboarding
user_pref("browser.onboarding.newtour", "performance,private,addons,customize,default");
user_pref("browser.onboarding.updatetour", "performance,library,singlesearch,customize");
user_pref("browser.onboarding.enabled", false);

// New tab settings
user_pref("browser.newtabpage.activity-stream.showTopSites",false);
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories",false);
user_pref("browser.newtabpage.activity-stream.feeds.snippets",false);
user_pref("browser.newtabpage.activity-stream.disableSnippets", true);
user_user_pref("browser.newtabpage.activity-stream.tippyTop.service.endpoint", "");

// Disable push notifications
user_pref("dom.webnotifications.enabled",false);
user_pref("dom.webnotifications.serviceworker.enabled",false);
user_pref("dom.push.enabled",false);

// Disable recommended extensions
user_pref("browser.newtabpage.activity-stream.asrouter.useruser_prefs.cfr", false);
user_pref("extensions.htmlaboutaddons.discover.enabled", false);
user_pref("extensions.htmlaboutaddons.recommendations.enabled", false);

// Disable the settings server
user_pref("services.settings.server", "");

// Disable use of WiFi region/location information
user_pref("browser.region.network.scan", false);
user_pref("browser.region.network.url", "");

// Disable VPN/mobile promos
user_pref("browser.contentblocking.report.hide_vpn_banner", true);
user_pref("browser.contentblocking.report.mobile-ios.url", "");
user_pref("browser.contentblocking.report.mobile-android.url", "");
user_pref("browser.contentblocking.report.show_mobile_app", false);
user_pref("browser.contentblocking.report.vpn.enabled", false);
user_pref("browser.contentblocking.report.vpn.url", "");
user_pref("browser.contentblocking.report.vpn-promo.url", "");
user_pref("browser.contentblocking.report.vpn-android.url", "");
user_pref("browser.contentblocking.report.vpn-ios.url", "");
user_pref("browser.privatebrowsing.promoEnabled", false);

user_pref("permissions.default.geo", 2);
user_pref("permissions.default.camera", 2);
user_pref("permissions.default.microphone", 2);
user_pref("permissions.default.desktop-notification", 2);
user_pref("permissions.default.xr", 2);
user_pref("media.autoplay.default", 5);
user_pref("media.autoplay.blocking_policy", 2);
user_pref("media.autoplay.allow-extension-background-pages", false);
user_pref("media.autoplay.block-event.enabled", true);

// https://github.com/nikitastupin/stop-firefox-automatic-connections/blob/master/user.js
user_pref("network.prefetch-next", false);
user_pref("network.dns.disablePrefetch", true);
user_pref("browser.aboutHomeSnippets.updateUrl", "");
user_pref("browser.newtabpage.activity-stream.feeds.snippets", false);
user_pref("app.normandy.enabled", false);
user_pref("dom.push.connection.enabled", false);
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
user_pref("browser.newtabpage.activity-stream.telemetry", false);
user_pref("browser.ping-centre.telemetry", false);
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("toolkit.telemetry.bhrPing.enabled", false);
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.firstShutdownPing.enabled", false);
user_pref("toolkit.telemetry.hybridContent.enabled", false);
user_pref("toolkit.telemetry.newProfilePing.enabled", false);
user_pref("toolkit.telemetry.reportingpolicy.firstRun", false);
user_pref("toolkit.telemetry.shutdownPingSender.enabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.updatePing.enabled", false);
user_pref("toolkit.telemetry.server", "");
user_pref("extensions.update.enabled", false);
user_pref("services.sync.prefs.sync.extensions.update.enabled", false);
user_pref("messaging-system.rsexperimentloader.enabled", false);
user_pref("app.normandy.optoutstudies.enabled", false);
user_pref("extensions.getAddons.cache.enabled", false);
user_pref("privacy.userContext.enabled", false);
user_pref("privacy.userContext.ui.enabled", false);
