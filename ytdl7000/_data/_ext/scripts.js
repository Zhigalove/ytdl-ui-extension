
import * as translations from "./translations.js";

let _CONFIG = {
    lang: null,
    version: 11,
    checkBoxes: {
        chooseSavedir: false,
        loadFullPlaylist: false,
        savePlaylistInExtraFolder: true,
        usePlaylistNumeration: true,
        invertPlaylistNumeration: false,
        skipErrors: false,
        audioOnly: false,
        useSponsorBlock: true,
        passCookies: false
    },
    fields: {
        maxQuality: "2160",
        restartAttempts: "5",
        playlistItems: "",
        savedirPath: "",
        proxyParam: ""
    }
};
let _config = window.localStorage.getItem("config");
if (_config) {
    _config = JSON.parse(_config);
    if ("checkBoxes" in _config) {
        _CONFIG.checkBoxes = {..._CONFIG.checkBoxes, ..._config.checkBoxes};
    };
    if ("fields" in _config) {
        _CONFIG.fields = {..._CONFIG.fields, ..._config.fields};
    };
    if (("lang" in _config) && (_config.lang in translations)) {
        _CONFIG.lang = _config.lang;
    };
    if (((!("version" in _config)) || (_config.version < 9)) && (_CONFIG.fields.maxQuality == "1080")) {
        _CONFIG.fields.maxQuality = "2160";
    };
    window.localStorage.setItem("config", JSON.stringify(_CONFIG));
};


function setLang() {

    let browserLanguage = navigator.language;
    if ((typeof chrome !== "undefined") && chrome.i18n && chrome.i18n.getUILanguage) {
        browserLanguage = chrome.i18n.getUILanguage();
    };

    let lang = _CONFIG.lang;
    if ((!lang) && browserLanguage) {
        lang = new Intl.Locale(browserLanguage).language;
    };
    if (!(lang in translations)) {
        lang = "ru";
    };

    document.documentElement.lang = lang;

    document.title = translations[lang].main_title;

    let element;
    for (let key in translations[lang]) {
        element = document.getElementById(key);
        if (element) {
            element.textContent = translations[lang][key];
        };
    };

    const savedirPath = document.getElementById("savedirPath");
    if (savedirPath) {
        savedirPath.placeholder = translations[lang].savedirPathPlaceholder;
    };

    for (const [elementId, titleKey] of [
        ["useSponsorBlockInfo", "useSponsorBlockTitle"],
        ["playlistItemsInfo", "playlistItemsTitle"]
    ]) {
        const infoElement = document.getElementById(elementId);
        const title = translations[lang][titleKey];
        if (infoElement && title) {
            infoElement.dataset.tooltip = title;
            infoElement.setAttribute("aria-label", title);
        };
    };

    for (const button of document.querySelectorAll(".lang-button")) {
        button.classList.toggle("active", button.dataset.lang == lang);
    };
};

function updateQualityPresets() {
    const element = document.getElementById("maxQuality");
    if (!element) {
        return;
    };

    for (const preset of document.querySelectorAll(".quality-preset")) {
        preset.classList.toggle("active", preset.dataset.quality == element.value);
    };
};

async function startDownload() {

    const [tab] = await chrome.tabs.query({active: true, currentWindow: true});

    let requestData = {};

    let element = document.getElementById("maxQuality");
    if (element.value) {
        const maxQuality = Number(element.value);
        if (!Number.isNaN(maxQuality)) {
            requestData["best-height"] = maxQuality;
        };
    };

    element = document.getElementById("chooseSavedir");
    if (element.checked) {
        requestData["savedir"] = ":autoChoice:";
    } else {
        element = document.getElementById("savedirPath");
        if (element.value.trim()) {
            requestData["savedir"] = element.value.trim();
        };
    };

    element = document.getElementById("loadFullPlaylist");
    if (element.checked) {
        requestData["load-full-playlist"] = true;
    };

    element = document.getElementById("savePlaylistInExtraFolder");
    if (element.checked) {
        requestData["use-playlist-extra-folder"] = true;
    };

    element = document.getElementById("usePlaylistNumeration");
    if (element.checked) {
        requestData["use-playlist-numeration"] = true;
    };

    element = document.getElementById("invertPlaylistNumeration");
    if (element.checked) {
        requestData["invert-playlist-numeration"] = true;
    };

    element = document.getElementById("playlistItems");
    if (element.value) {
        requestData["playlist-items"] = element.value;
    };

    element = document.getElementById("skipErrors");
    if (element.checked) {
        requestData["skip-error"] = true;
    };

    element = document.getElementById("audioOnly");
    if (element.checked) {
        requestData["audio-only"] = true;
    };

    element = document.getElementById("useSponsorBlock");
    if (element.checked) {
        requestData["use-sponsorblock"] = true;
    };

    element = document.getElementById("restartAttempts");
    if (element.value) {
        requestData["restart-attempts"] = Number(element.value);
    };

    element = document.getElementById("passCookies");
    if (element.checked) {

        let cookies = await chrome.cookies.getAll({url: tab.url});

        if (cookies.length >= 1) {

            let cookiesNetscape = "# Netscape HTTP Cookie File\n";
            for (const cookie of cookies) {

                cookiesNetscape += cookie.domain;
                cookiesNetscape += "\t";

                cookiesNetscape += (cookie.domain.startsWith(".")) ? "TRUE" : "FALSE";
                cookiesNetscape += "\t";

                cookiesNetscape += cookie.path;
                cookiesNetscape += "\t";

                cookiesNetscape += (cookie.httpOnly) ? "TRUE" : "FALSE";
                cookiesNetscape += "\t";

                cookiesNetscape += (cookie.expirationDate) ? String(Math.round(cookie.expirationDate)) : "";
                cookiesNetscape += "\t";

                cookiesNetscape += cookie.name;
                cookiesNetscape += "\t";

                cookiesNetscape += cookie.value;

                cookiesNetscape += "\n";

            };

            requestData["cookies-txt"] = cookiesNetscape;

        };
    };

    element = document.getElementById("proxyParam");
    if (element.value) {
        requestData["proxy"] = element.value;
    };

    await chrome.runtime.sendMessage({
        command: "startDownload",
        url: tab.url,
        tabId: tab.id,
        windowId: tab.windowId,
        requestData: requestData
    });
};

function init() {

    let element;

    for (let key in _CONFIG.checkBoxes) {
        element = document.getElementById(key);
        if (element) {
            element.checked = _CONFIG.checkBoxes[key];
            element.addEventListener(
                "click",
                function() {
                    const _element = document.getElementById(key);
                    _CONFIG.checkBoxes[_element.id] = _element.checked;
                    window.localStorage.setItem("config", JSON.stringify(_CONFIG));
                }
            );
        };
    };


    for (let key in _CONFIG.fields) {
        element = document.getElementById(key);
        if (element) {
            element.value = _CONFIG.fields[key];
            const eventName = (element.tagName == "SELECT") ? "change" : "input";
            element.addEventListener(
                eventName,
                function() {
                    const _element = document.getElementById(key);
                    _CONFIG.fields[_element.id] = _element.value;
                    window.localStorage.setItem("config", JSON.stringify(_CONFIG));
                    if (_element.id == "maxQuality") {
                        updateQualityPresets();
                    };
                }
            );
        };
    };

    for (const preset of document.querySelectorAll(".quality-preset")) {
        preset.addEventListener(
            "click",
            function() {
                const element = document.getElementById("maxQuality");
                element.value = preset.dataset.quality;
                _CONFIG.fields.maxQuality = element.value;
                window.localStorage.setItem("config", JSON.stringify(_CONFIG));
                updateQualityPresets();
            }
        );
    };
    updateQualityPresets();

    for (const button of document.querySelectorAll(".lang-button")) {
        button.addEventListener(
            "click",
            function() {
                _CONFIG.lang = button.dataset.lang;
                window.localStorage.setItem("config", JSON.stringify(_CONFIG));
                setLang();
            }
        );
    };

    element = document.getElementById("startDownload");
    element.addEventListener("click", startDownload);

};

setLang();
init();
