# Rainbow

Text coloring/sizing per character for luxe. Different font is not supported yet.

Example:

```haxe
new RichText
({
    text : "Hel{red}lo {white}w{red}orld",
    pos : Luxe.screen.mid,
    color : new Color().rgb(0x276BE8),  // Default color
    tags : [new Tag("red", new Color().rgb(0xE8273C)),
            new Tag("white", new Color())],
    align : TextAlign.center,
    size : 50,
});
}
```
