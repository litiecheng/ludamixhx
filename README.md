# Ludamix Haxe Libraries

These are "data centric" libraries useful to game and media application programming. They primarily revolve around data modelling problems that come up over and over again and abstractions I've made over the years to resolve them. The different packages are generally independent of each other, and some are based on code from older repositories I have on GitHub. More on each library below.

# Philosophy

Most data should be in primitive types, not elaborate containers. Friction derives from prematurely abstracting the data. Additional abstraction should appear at the moment you design your application code.

* Int is used almost everywhere because it is primitive. It can be used as a lookup ID.
* Array\<Int\> or Vector\<Int\> are commonly used to store groups of data.

When attempting to make garbage-collected code useful for soft real-time applications, avoiding unnecessary allocation is critical. Some of the Ludamix libraries make accomodations for this problem. I use different approaches at different times somewhat arbitrarily, based on the code's origins.

* Load/store formalism on the class: The class is populated by copying in the data, and the algorithm returns a result by mutating the data it holds, avoiding tiny heap allocations.
* Data-in-vector: The class treats a large numeric Vector as multiple instances of a more complex record type, avoiding indirection and tracing costs.
* Object pool: Many of the same object are held in a container and toggled on and off as necessary to avoid "thrashing" in the garbage collector.

## Buffer

An allocator for Float and Int data that uses a fixed-size slab/pool/chunk approach to memory management. It accommodates allocations of multiple regions as a single buffer, buffers with padding data(very useful for debugging), and additionally has a wrapper to support stacks of data in this system.

## CircularVector1, CircularVector2

Vector wrappers that let you write to and address ring buffers. Good for queues of limited size.

## GrowVector1, GrowVector2, GrowVector3, GrowVector4, GrowVector8

These are Vector wrappers that contain an additional length, an automatic (doubling) resize, a reader pointer, and a "struct size" according to the number(1,2,3,4,8) making it easy to bundle multiple values per index.

## Grid.hx

A 1-dimensional abstraction for storing 2-dimensional tilemap data. It assumes tiles are integers.

## QuantizedRect.hx

This solves an apparently simple problem: If I have a rectangle of arbitrary size positioned on a grid, how large is it in terms of the grid's tiles? Which tiles does it intersect with? This algorithm returns the result of such a quantization process.

## bmfont

Raw data structures and parser for the XML form of Angelcode's BMFont library. 

### BMFont.hx

Basic file loading functionality. You can process this into your own renderer's format.

### BMFontRenderPage.hx

A state machine style rendering system. The template type T contains formatted image data in your API or framework - the classes themselves do not use require this data.

Use BMFontWriter.begin(), write(), and end() to write character data into a buffer. Loop over the results in "buf" and "pg" to draw final output. breakLine() and wrap() if you need to format a paragraph.

Example:

```Haxe

// (using Kha framework abstractions)

var bf = BMFont.parse(bmfont_xml)[0];
var bfmap = new Map<String, BMFontRenderPage<Image>>();

for (page in bf.page) {
    var rp = new BMFontRenderPage<Image>(page);
    // fix path
    var p = page.file;
	p = StringTools.replace(p, ".png", "");
	p = StringTools.replace(p, ".", "_");
	var slash = p.lastIndexOf("/");
	if (slash >= 0)
		p = p.substr(slash, p.length);
	// async load the actual image
    var fload = (Reflect.field(Assets.images, p + "Load"));
    fload(function(r){rp.image = r;});
    bfmap.set(page.file, rp);
}

// ... after loading, render:

var bmfr = new BMFontRenderable(bf, bfmap);

var fw = new BMFontWriter();
fw.begin([bmfr], 0, 0., 0.);
var testtext = "Hello World!";
fw.wrap(BMFontWriter.breakLine(testtext, true), 300.);
fw.end();
fw.translateTopLeft(64, 32);
		
for (cidx in 0...fw.len) {
	var bufi = fw.bufpos(cidx);
	framebuffer.g2.drawScaledSubImage(
		fw.font[fw.fn[cidx]].page[fw.pg[cidx]].image, 
		fw.buf[bufi], fw.buf[bufi+1], 
		fw.buf[bufi+2], fw.buf[bufi+3], 
		fw.buf[bufi+4], fw.buf[bufi+5], 
		fw.buf[bufi+6], fw.buf[bufi+7]);
}
```

## computedstack

This implements a stack of multiple customized vector data structures on top of GrowVector. For example, if you want to have a sum of integers or an exponentiation of floats, but want to abstract it so that you are only "working with" the last element of the list(e.g. hierarchy of positioning data).

## contrig

Controller trigger abstractions. The event-based abstractions that are popular today are a poor match for some common functionality in game character control; this is a structure that will tell you when and for how long(in units of your choosing) a button has been pressed or depressed. It also holds analog data(but does very little with it).

```haxe

var contrig = new Contrig();

contrig.addDigital("Fire");

contrig.setDown("Fire");
contrig.pump();
contrig.pump();
contrig.pump();
contrig.pump();
trace(contrig.downLength("Fire")); // 4

```

## erec

Entity Rectangle abstractions. This is for typical 2D game characters using axis-aligned bounding boxes, with collision masks, a type, and an owner. Besides storing them, it can perform typical collision functions, using load/store semantics. Use the functions to build up your own collision routine, for example:

```haxe

// load two entities and pushout the first above the second.

erec.loadA(e0);
erec.loadB(e1);

if (erec.intersect()) erec.pushoutTop();

```

## grassi

Graphics Asset Instancing System. This holds an object pool of common renderable positioning data: x, y, z, type, index. It also sorts by z. There are two x and y positions in order to support interpolated rendering.

## kha

These are data structures and rendering abstractions designed specifically for the Kha framework, in 2D drawing situations. I plan to add my whole renderer here at some point, as I find better means of decoupling it.

## log

A logging tool that efficiently stores events.

## painter

This used to be "libpainter". It contains a set of algorithms for painting and pathfinding on a bitmap, and a structure for describing "paint tool state", making it possible to quickly build a feature-rich painting program. I have provided some orientation documentation in the library's subfolder.

## pixelbound

This loads data from my sprite sheet application, [Pixelbound](http://triplefox.itch.io/pixelbound).

## proframe

Simple frame profiling tool. Lets you track different slices as well as a total time. Does not do averaging(right now).

```haxe
var pf = new Proframe([
	"slice_a",
	"slice_b"
], "ms");

pf.start(Lib.getTimer());
sliceA();
pf.log("slice_a", Lib.getTimer());
sliceB();
pf.log("slice_b", Lib.getTimer());
pf.end(Lib.getTimer())

trace(pf.report());

```

## Ivy

A tiny interpreted state machine, one in a series of such machines that I've developed. It uses a form of cooperative multitasking in which the program can push a stack of additional programs, and runs them bottom-to-top in each pass. This formulation makes the semantics of behavior tree AI available in a form which also neatly collapses down to simple linear "cutscene" type behavior. Ivy supports integer variables 

This will be supplemented with my behavior tree compilation suite soon. I still have some proof work to do before I feel comfortable pushing it to ludamix.