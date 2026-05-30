
async function sleep(ms) {
    return new Promise(((resolve) => setTimeout(resolve, ms)));
};

function randInt(minValue, maxValue) {
    return Math.round((minValue + (Math.random() * (maxValue - minValue))));
};

async function openYtdlUri(uri, tabId, windowId) {
    if (tabId !== undefined) {
        try {
            await chrome.tabs.update(tabId, {url: uri});
            return null;
        } catch (ex) {
            console.error(ex);
        };
    };

    const createProperties = {url: uri, active: true};
    if (windowId !== undefined) {
        createProperties.windowId = windowId;
    };

    const tab = await chrome.tabs.create(createProperties);
    return tab.id;
};

async function _main(url, requestData, tabId, windowId) {

    console.debug(`Download from URL: ${url}`);
    console.debug(`Request data: ${JSON.stringify(requestData)}`);

    const port = randInt(1024, 65535);
    console.debug(`Data port: ${port}`);

    const _uri = `ytdl7000:\"${url}\" --data-port \"${port}\"`;
    const localURL = new URL(`http://localhost:${port}`);

    console.debug("Open URI scheme");
    const startTabId = await openYtdlUri(_uri, tabId, windowId);

    let _attempt = 0;
    while (true) {
        _attempt += 1;
        if (_attempt > 15) {
            break;
        };
        try {
            console.debug(`Send data (attempt ${_attempt})`);
            const resp = await fetch(
                localURL,
                {
                    method: "POST",
                    headers: {"Content-Type": "application/json;charset=utf-8"},
                    body: JSON.stringify(requestData)
                }
            );
            if (resp.ok) {
                console.debug("Success");
                break;
            };
        } catch (ex) {
            console.error(ex);
        };
        await sleep((_attempt * 1000));
    };
    if (startTabId !== null) {
        console.debug("Close tab");
        try {
            await chrome.tabs.remove(startTabId);
        } catch (ex) {
            // If user close tab.
            console.error(ex);
        };
    };
    console.debug("Done");
};


chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
    if (message.command == "startDownload") {
        console.debug("Start main script");
        _main(message.url, message.requestData, message.tabId, message.windowId);
        console.debug("End listener");
    };
});
