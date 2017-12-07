# Chef Sizzle
Hear what's Cooking!

<img src="assets/screenshot-single.png" alt="screenshot" height="400"/>

### Summary

Chef Sizzle is a cooking assistant app written for iOS, which uses voice recognition and speech synthesis to give the user a hands free experience. While cooking, control the flow of the cooking instructions using your voice. You will never have to put down your knife or wash your hands just to find out what you should be doing next.

### General Design Approach

...

### Technical Implementations

#### Frameworks used
Currently, voice recognition is accomplished using the **SFSpeechRecognition** class from Apple's **Speech** framework. Speech synthesis uses the **AVSpeechSynthesizer** class from Apple's **AVFoundation** module

#### Issues and Setbacks

Keeping track of and responding to changes in the voice recognition engine proved to be difficult. There are two methods for invoking a voice recognition task. One uses a delegate to handle the state changes and results. Which in theory would work well. Unfortunately seems to not work for some states and the results took a long time to process, making the app lag significantly. The second utilizes a closure, return results and errors. The recognition was fast and easy to set up. The state changes were passed via "error" codes. Which conceptually is an odd choice and not obviously stated. The errors themselves are not very descriptive and the error codes are not documented anywhere. Handling state changes required trial and error to guess what each one meant so that behavior could be implemented.

### Documentation

[Release Notes](documentation/release-notes.md) - Beta 0.2.0

Project Proposal - \[[keynote](documentation/Proposal.key)\] \[[power point](documentation/proposal.pptx)\] \[[google slides](https://docs.google.com/presentation/d/175Emj1Y6r1BjidKc95un5fMljHHE-9Nv1oms9oDnocs/edit#slide=id.g2b9498d323_2_50)\] \[[pdf](documentation/proposal.pdf)\]

[Research Summary](documentation/research.md) - Summary, goals, questions, methodology, scripts, persona results, problem statement, and initial prototype UI.

### URL's

[Test Flight]() - Beta is not currently publicly available
