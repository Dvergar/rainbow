package rainbow;

import luxe.Color;
import luxe.Text;
import luxe.Vector;
import phoenix.BitmapFont;
import phoenix.Batcher;
using StringTools;


class Tag {
    public var color:Color;
    public var text:String;
    public var index:Int;

    public function new(text:String, color:Color) {
        this.color = color;
        this.text = text;
    }

    public function clone() {
        return new Tag(text, color);
    }

    function toString() {

        return "{ color:"+color + ", text:" + text + ", index:" + index + " }" ;
    }
}


typedef TagData = {pos:Int, len:Int, color:Color, size:Float, text:String};
class RichText {
    public var text_options : Dynamic;
    var text_chunks : Array<Text> = new Array();
    var rich_text_options : Dynamic;
    var tags : Array<Tag>;
    var align : TextAlign;
    var font : BitmapFont;
    var batcher : Batcher;
    var depth : Int;
    var color : Color;
    var chunk_pool : Map<String, Array<Text>> = new Map();
    @:isVar public var size (default,set) : Float;
    @:isVar public var pos (default,set) : Vector;
    @:isVar public var text (default,set) : String;
    @:isVar public var visible (default,set) : Bool;

    public function new( _options : Dynamic ) {
        if(_options.pos == null) {
            _options.pos = new Vector();
        }

        if(_options.text == null) {
            _options.text = "";
        }

        if(_options.text == null) {
            _options.align = TextAlign.left;
        }

        if(_options.size == null) {
            _options.size = 24;
        }

        if(_options.color == null) {
            _options.color = new Color();
        }

        if(_options.tags == null) {
            _options.tags = new Array();
        }

        // ORDER MATTERS, CAREFUL
        batcher = _options.batcher;
        font = _options.font;
        pos = _options.pos;
        tags = _options.tags;
        align = _options.align;
        size = _options.size;
        color = _options.color;
        depth = _options.depth;
        text = _options.text;
    }

    function chunk_real_size(chunk:Text) {
        // var scale_cache = new Vector();
        // scale_cache.x = scale_cache.y = chunk.textsize/chunk.font.font_size;

        // return chunk.font.get_text_dimensions(chunk.text, scale_cache);

        return chunk.font.width_of(chunk.text, size) / 1.2;  // AWFUL WORKAROUND / 1.2
    }

    public function set_visible(visibility:Bool)
    {
        for(chunk in text_chunks)
            chunk.visible = visibility;

        return visibility;
    }

    public function set_pos(new_pos:Vector) {

        var width:Float = 0;
        for(chunk in text_chunks) {
            width += chunk_real_size(chunk);
            // width += chunk_real_size(chunk).x;
        }

        var real_x = new_pos.x;
        if(align == TextAlign.center)
            real_x -= width / 2;
        if(align == TextAlign.right)
            real_x -= width;

        for(chunk in text_chunks) {
            var dim = chunk_real_size(chunk);
            // chunk.pos = new Vector(real_x, chunk.pos.y);
            chunk.pos = new Vector(real_x, new_pos.y);
            // real_x += dim.x;
            real_x += dim;
            // real_x += chunk.point_size;
        }

        return pos = new_pos;
    }

    public function set_size(new_size:Float) {
        for(chunk in text_chunks) {
            chunk.point_size = new_size;
        }
        size = new_size;
        set_pos(pos);

        return new_size;
    }

    public function set_text(new_text:String) {
        var tag_datas:Array<TagData> = new Array();
        var r = ~/\{(\w*)\}/;

        var reg_text = new_text;
        var dpos = 0;
        while(r.match(reg_text)) {

            var m = r.matchedPos();

            var tagName = r.matched(1);

            // TAG COLORS
            for(tag in tags)
            {
                if(tag.text == tagName)
                {
                    reg_text = r.matchedRight();
                    dpos += m.len;
                    m.pos = new_text.length - reg_text.length - dpos;

                    var tag_data:TagData = cast m;
                    tag_data.color = tag.color;
                    tag_data.text = tag.text;
                    tag_datas.push(tag_data);
                }
            }

            // TAG BOLD (REFACTOR)
            if(tagName == "b")
            {
                reg_text = r.matchedRight();
                dpos += m.len;
                m.pos = new_text.length - reg_text.length - dpos;
                var tag_data:TagData = cast m;
                tag_data.size = size * 1.20;
                tag_data.text = "b";
                tag_datas.push(tag_data);
            }

        }

        // REMOVE TAG FROM TEXT
        var clean_text:String = new_text;
        for(tag in tags) {
            clean_text = clean_text.replace("{" + tag.text + "}", "");
        }
        clean_text = clean_text.replace("{b}", "");

        // POOL OLD CHUNKS
        for(chunk in text_chunks)
        {
            // chunk.destroy();
            chunk.visible = false;
            chunk_pool.get(chunk.text).push(chunk);
        }

        // RESET POOLED CHUNKS
        // Luxe.debug.start('cleancreate');
        text_chunks = new Array();

        // TODO : name that part, it's not reset chunk part
        for(i in 0...clean_text.length) {

            // PROFILE INNER LOOPS
            var letter = clean_text.charAt(i);
            var letter_pool = chunk_pool.get(letter);

            if(letter_pool == null)
            {
                letter_pool = new Array();
                chunk_pool.set(letter, letter_pool);
            }

            var text_chunk = letter_pool.pop();

            if(text_chunk == null)
            {
                text_chunk = new Text({
                    font : font,
                    text : letter,
                    pos : pos,
                    point_size : size,
                    batcher : batcher,
                    align_vertical : center,
                });
            }

            text_chunk.depth = depth;
            text_chunk.color = color;
            text_chunk.visible = true;
            text_chunks.push(text_chunk);
        }
        // Luxe.debug.end('cleancreate');

        var i = clean_text.length;
        var tag_i = tag_datas.length;
        while(tag_i-- > 0) {
            var tag_data = tag_datas[tag_i];
            for(j in tag_data.pos...i) {
                if(tag_data.color != null) text_chunks[j].color = tag_data.color;
                if(tag_data.size != null)
                    text_chunks[j].point_size = tag_data.size;
            }
            i = tag_data.pos;
        }

        set_pos(pos);

        return text = clean_text;
    }
}