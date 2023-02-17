# LiveView: Upload and live update events

## Introduction

This attempt to use Phoenix.LiveView to handle file upload and live changes in the public page's textarea.

## What was used?

I tried the Phoenix.LiveView v0.17.5 and the latest v0.18.14.

The whole public page was programmed with LiveView, with events attached to the textarea and the upload input form.

The upload worked successfully using the progress event to update a progress bar with the feedback of the sending.

On the textarea, I tried to use a form to track changes (with phx-change), tried the keyup event, used throttle, debouncing and JS-Hooks.

THe mount function on the public page's live view subscribed at a topic, which receives when another user inserted a new data in the textarea. This new data was updated via liveview's socket assign, and the re-render cicle updates the textarea value with the new text.

## Why was it abandoned?

The problem was that when the textarea was focused (or in active state), the update of liveview wasn't able to replace the value of it. This was tested in Google Chrome (110.0) and Firefox (109.0).

With the Channel emmiting updates and JS to change the value of textarea it works when the textarea is active or focused.

I also tried to use hooks with LiveView with the beforeUpdate event to remove focus of the textarea, but it still didn't work.

Because of that, I'm abandoning the usage of LiveView here, and possibly on all usages that it has to change an input value that the user can also change its value. Maybe if the input is disabled, this works.

## Lessons learned

LiveView is very flexible, versitle and easy to use, needing almost only HTML and Elixir to make a very live page.

But when the value that needs to be updated is an input, I suggest not to use LiveView (or LiveComponent).

To work around this problem, I suggest to use raw channels with Javascript to subscribe in this channel, and receive on the client the new value that the input need to have.

## Authors

* Murilo Rocha (2023-02-15)
