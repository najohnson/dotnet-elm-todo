import { Elm } from './main.elm';

let node = document.getElementById('main');

let app = Elm.Main.init({
    node,
    flags: process.env.API_BASE
});