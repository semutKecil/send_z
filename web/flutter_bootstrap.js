{{flutter_js}}
{{flutter_build_config}}
// const animation = document.createElement('div');
// animation.setAttribute("class", "loader");
// document.body.appendChild(animation);

const loading = document.createElement('div');
loading.setAttribute("class", "loader-text");
document.body.appendChild(loading);
loading.textContent = "Loading Entrypoint";

_flutter.loader.load({
    onEntrypointLoaded: async function (engineInitializer) {
        loading.textContent = "Initializing engine";
        let appRunner = await engineInitializer.initializeEngine({});
        loading.textContent = "Running app";
        appRunner.runApp();
    },
});