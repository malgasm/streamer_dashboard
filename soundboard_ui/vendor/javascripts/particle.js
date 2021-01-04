// jshint ignore: start
//calculate the amount of time it takes for an animation to complete and clear the canvas when the last animation has completed

class Emote {
  constructor() {
    var ctx = this;
    return new Proxy({}, {
      get: function(obj, prop) {
        return ctx.getEmote(prop);
      }
    })
  }
  getEmote(emote) {
    return `https://peanut/~m/streamer_dashboard_assets/${emote}.png`
  }
}

class Utility {
  getRandomInt(max) {
    return Math.floor(Math.random() * Math.floor(max));
  }
}

class ParticleAnimation {
  createCanvas(parentEl) {
    return document.createElement( 'canvas' );
  }

  appendCanvas(canvas, parentEl) {
    canvas.style.position = 'absolute';
    canvas.id = 'particles';

    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;

    // canvas.style.height = '100vh';
    // canvas.style.width = '100vw';
    parentEl.appendChild( canvas );
    return canvas;
  }

  constructor(parentEl, numParticles=52) {
    this.canvas = this.createCanvas();
    this.context = this.canvas.getContext( '2d' );
    this.particles = [];
    this.util = new Utility();

    this.appendCanvas(this.canvas, parentEl);
    requestAnimationFrame(this.animate.bind(this));
  }

  animateAtPosition(image, x, y) {
    this.particles.push(new Particle(image, x, y));
  }

  stopAnimation() {
    this.particles = [];
  }

  clearCanvas() {
    this.context.clearRect(0,0,window.outerWidth, window.outerHeight)
  }

  animate() {
    var i = 0, l = this.particles.length;
    if (this.particles.length == 0)
      this.particles = [];

    while ( i < l ) {

      if (this.particles[i].update(i))
        i++;
      else {
        this.removeParticleByIndex(i);
        l--;
      }
    }
    requestAnimationFrame( this.animate.bind(this) ); //todo: start/stop animation
  }

  removeParticleByIndex(idx) {
    this.particles.splice(idx, 1)
    if (this.particles.length == 0)
      this.clearCanvas()
  }

  animateCount(image, count) {
    for (var i=0; i < count; i++){
      this.animateAtRandomPosition(image)
    }
  }

  animateAtRandomPosition(image,
    xPos=this.util.getRandomInt(this.canvas.width),
    yPos=this.util.getRandomInt(this.canvas.height)) {
    this.animateAtPosition(image, xPos, yPos);
  }

  grinGasm(numFrames) {
    this.buildupAnimation([new Emote().grin], numFrames);
  }

  malGasm(numFrames) {
    var e = new Emote()
    this.buildupAnimation([e.grin, e.love, e.fire, e.peace, e.woot], numFrames);
  }

  buildupAnimation(emotes, numFrames = 100, maxParticles=35) {
    var frames = [],
      timeout = 10000,
      count = 1,
      ctx = this;
    var prevCount;

    for (var i = 0; i < numFrames; i++) {
      prevCount = count;
      count = count > maxParticles ? maxParticles : count + 1;
      frames.push({count: count, timeout: i * 150});
    }

    frames.map(function(frame) {
      window.setTimeout(function() {
        for (var i = 0; i < frame.count; i++) {
          ctx.animateAtRandomPosition(emotes[ctx.util.getRandomInt(emotes.length)]);
        }
      }, frame.timeout * 1);
    });
  }
}

class Particle {
  setImageSrc(imgSrc) {
    this.image.src = imgSrc;
  }

  getCanvas() {
     return document.getElementById('particles');
  }

  getContext() {
    return this.getCanvas().getContext( '2d' );
  }

  constructor(imgSrc, x, y, maxFrames=500) {
    this.x = x;
    this.y = y;
    this.sx = Math.floor( Math.random() * 6 - 3 ) * 2;
    this.sy = - Math.random() * 16;
    var image = document.createElement('img');
    image.src = imgSrc;
    this.image = image;
    this.frames = 0;
    this.maxFrames = maxFrames;
  }

  update(idx) {
    this.frames++;
    if ( this.sx === 0 ) this.sx = 2;
    var cwidth = 112, cwidthhalf = cwidth / 3;
    var cheight = 112, cheighthalf = cheight / 2;
    var canvas = this.getCanvas();

    this.x += this.sx;
    this.y += this.sy;

    if ( this.x < ( - cwidthhalf ) || this.x > ( canvas.width + cwidthhalf ) || this.frames > this.maxFrames ) {
      return false;
    }

    if ( this.y > canvas.height - cheighthalf ) {
      this.y = canvas.height - cheighthalf;
      this.sy = - this.sy * 0.89;
    }

    this.sy += 0.98;

    this.getContext().drawImage( this.image, 0,0, this.image.width, this.image.height, Math.floor( this.x - cwidthhalf ), Math.floor( this.y - cheighthalf ), this.image.width, this.image.height  );

    return true;
  }
}
