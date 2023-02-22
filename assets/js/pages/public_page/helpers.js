import getPage from "../../libs/get_page";
import domSelector from "./dom_selectors";
import { getTimerDebounceTextDataInput, getUrls, setTimerDebounceTextDataInput } from "./page_data";
import { getActiveInterval, getLastUpdateTotalSeconds, setActiveInterval, setLastUpdateTotalSeconds } from "./page_data";

const getTopic = () => {
    return `text_data:${getPage()}`
}

function debounceTextDataInput(func, millis = 500) {
    return (...args) => {
        clearTimeout(getTimerDebounceTextDataInput());
        const newTimeout = setTimeout(() => { func.apply(this, args); }, millis);
        setTimerDebounceTextDataInput(newTimeout);
    };
}

async function fileDeleteRequest(delete_path, fileId){
    const url = delete_path.replace("FILE_ID", fileId);
    const response = await fetch(url, {
        method: "delete",
        headers: {"Content-Type": "application/json"}
    });
}

const updateLastTimeComponent = () => {
    domSelector.lastUpdateTimediffSpan().innerHTML = `${getLastUpdateTotalSeconds()} seconds ago`;
    domSelector.lastUpdateTimediffSpan().parentElement.classList = [];
}

const registerUpdateLastTimeInterval = () => {
    let activeInterval = getActiveInterval();
    if (activeInterval !== undefined) {
        clearInterval(activeInterval);
    }
    activeInterval = setInterval(() => {
        const lastUpdateTotalSeconds = getLastUpdateTotalSeconds();
        if (lastUpdateTotalSeconds !== undefined) {
            setLastUpdateTotalSeconds(lastUpdateTotalSeconds + 1);
            updateLastTimeComponent();
        };
    }, 1000.0);
    setActiveInterval(activeInterval);
}

const updateTimeDiff = () => {
    setLastUpdateTotalSeconds(0);
    updateLastTimeComponent();
    registerUpdateLastTimeInterval();
}

const registerFileListEvents = () => {

    domSelector.deleteFileButtonList().forEach(el => {
        el.addEventListener("click", (event) => {
            event.stopPropagation();
            const target = event.currentTarget;
            const fileId = target.parentNode.getAttribute("file-id");

            fileDeleteRequest(getUrls().deleteFile, fileId);
        })
    });

    domSelector.downloadFileRowList().forEach(el => {
        el.addEventListener("click", (event) => {
            const target = event.currentTarget;
            const fileId = target.getAttribute("file-id");
            const fileName = target.getAttribute("file-name");

            window.open(getUrls().downloadFile.replace("FILE_ID", fileId).replace("FILE_NAME", fileName));
        })
    });

}

export {
    getTopic,
    fileDeleteRequest,
    debounceTextDataInput,
    updateLastTimeComponent,
    registerUpdateLastTimeInterval,
    updateTimeDiff,
    registerFileListEvents
}