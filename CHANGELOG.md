## [v5.2.2-1] - 2022-01-26

- **fixed:** [ec60414f1ee26a4c4daf66ccc7935d6a74a3a20c] It was not possible to click on RegnumStarter UI after Regnum has been launched on Windows 11 which prevents players from starting Regnum multiple times at the same time, this is fixed.
- **added:** [b5294398d82dcb2fe90bbc7b1215eb7953cef10a] Feature request: Checkbox underneath Login button to selecet if RegnumStarter should stay open or close after logging in to Regnum. Please note that as of now RegnumStarter will close after the Regnum client has been closed too. This will be changed in a further update.
- **removed:** [44800a4f55402cec4268cd4ebd4a1009b5232039] Regnum News and Server Status have been removed. Server Status is no longer needed and Regnum News don't work the way they had been implemented initially.
- **changed:** AutoHotKey updated to 1.1.34.00

## some versions missing here...

## [v4.0.2-pre] - 2020-05-11

- **fixed:** [7f4dec8f32fe5298052d6635168c87a128961832] Shurtcuts are now working again.

## [v4.0.1-pre] - 2020-05-10

- **hotfix:** A wrong variable in the configuration file prevented the RegnumStarter from starting.

If you updated to v4.0.0 previously, please download the latest release manually and replace it with your existing RegnumStarter.exe

## [v4.0.0-pre] - 2020-05-09

- **changed:** [28e0f19b2a86f0f8a49145e8673fc4490ee6bd57] New window layout and background image.
- **added:** [f57c5db5a4dd8e3e25033e3faf674afe978d6994] Added images and links to the cor-forum.de website and Discord servers.
- **added:** [fa65177d2d7436297fb7db3037e3f6af2f961c66] Champions of Regnum Logo.
- **added:** [b71b676f47f9f80a4ff42775637f695f3134ff22] Regnum News.
- **added:** [b75c721fc8c5cbc6af94a2f3fc1b5c9226ed7707] New Settings window. The mess of options has been moved into this menu.
- **added:** Relevant translations.
- **hotfix:** [fd125e7ff03844c4582155690cda4dd19a235806] Added explanation to the language selection on first start, as the dropdown window is bugged.
- **fixed:** [4f3dea5cbdd911f91a7c0a5f19e13abbc4b8137d] RegnumStarter now allows only one instance to run at a time. This prevents one instance overwriting the config files of another and fixes some AHK bugs.
- **fixed:** [156b00d6f5d58eed6bd85b17200f18ce96044e3f] RegnumStarter will now make sure that all needed files are in place, all the time.
- **changed:** Refactored a lot of functions.

Please note that this is a pre-release version and many objects might be changed in the near future.

## [v3.2.1] - 20-04-29

- **fixed:** [ba1446041a23fc2366297135f71fc84d422472b9] Extremly loud NGE Intro is now hiding correctly if "Hide NGE-Intro" is checked. Please note issue #6
- **fixed:** [b8ec0aeb1668520fb790a36fd8006fb08ab942a7] No more "," will be added behind the value of emluated latency

## [v3.2.0] - 2020-04-26

- **fixed:** [34f845e09661c81153a17f627c99a7fe00991f54] Game update detection method
- **fixed:** [82dc5b0635271aeec135c6a4437c98c49ed9084b] Use https to connect to cor-forum.de; fixes bug that prevented the client from loading the serverConfig.txt
- **added:** [417c1e402ef501c5bffb596d09d26ee5b0b18baa] Link to Forum Post
- **changed:** [80085a05b1e85da7bedaefff574f463568fb3adb] serverConfig.txt is now fetching async, so it isnt UI-blocking and properly handles offline mode


## [v3.1.0] - 2019-11-29

- **added:** RegnumStarter logo in Taskbar
- **changed:** Old Server "Haven" is no longer in the server list
- **changed:** RegnumStarter is no longer trying to hide the gamigo logo as it has been removed by NGE
- **changed:** NGE logo can now be hidden
