import getPage from "../../libs/get_page";
import domSelector from "./dom_selectors";
import { getTimerDebounceTextDataInput, setTimerDebounceTextDataInput } from "./page_data";
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
    console.log(response);
    location.reload();
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

export {
    getTopic,
    fileDeleteRequest,
    debounceTextDataInput,
    updateLastTimeComponent,
    registerUpdateLastTimeInterval,
    updateTimeDiff
}