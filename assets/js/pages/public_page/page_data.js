let lastUpdateTotalSeconds = undefined;
let activeInterval = undefined;
let timerDebounceTextDataInput = undefined;
let urls = {
    deleteFile: undefined,
    uploadFile: undefined,
    downloadFile: undefined
}

export function getLastUpdateTotalSeconds() {
    return lastUpdateTotalSeconds;
}

export function setLastUpdateTotalSeconds(value) {
    lastUpdateTotalSeconds = value;
}

export function getActiveInterval(){
    return activeInterval;
}

export function setActiveInterval(value){
    activeInterval = value;
}

export function getTimerDebounceTextDataInput(){
    return timerDebounceTextDataInput;
}

export function setTimerDebounceTextDataInput(value){
    timerDebounceTextDataInput = value;
}

export function getUrls() {
    return urls;
}

export function setUrls(value) {
    urls = value;
}

export default {
    getLastUpdateTotalSeconds,
    setLastUpdateTotalSeconds,
    getActiveInterval,
    setActiveInterval,
    getTimerDebounceTextDataInput,
    setTimerDebounceTextDataInput,
    getUrls,
    setUrls
}