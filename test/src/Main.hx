import luxe.Input;
import luxe.Color;
import phoenix.BitmapFont;

import rainbow.RichText;


class Main extends luxe.Game {

    override function ready() {
        new RichText
        ({
            text : "Hel{red}lo {white}w{red}or{b}ld",
            pos : Luxe.screen.mid,
            color : new Color().rgb(0x276BE8),  // Default color
            tags : [new Tag("red", new Color().rgb(0xE8273C)),
                    new Tag("white", new Color())],
            align : TextAlign.center,
            depth : 100,
            size : 50,
            // font : _options.font,
            // batcher : _options.batcher,
        });
    } //ready

    override function onkeyup( e:KeyEvent ) {

        if(e.keycode == Key.escape) {
            Luxe.shutdown();
        }

    } //onkeyup

    override function update(dt:Float) {

    } //update


} //Main
