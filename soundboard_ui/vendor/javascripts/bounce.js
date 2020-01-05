;
(function() {
  var lastTime = 0;
  var vendors = ['webkit', 'moz'];
  for (var x = 0; x < vendors.length && !window.requestAnimationFrame; ++x) {
    window.requestAnimationFrame = window[vendors[x] + 'RequestAnimationFrame'];
    window.cancelAnimationFrame = window[vendors[x] + 'CancelAnimationFrame'] || window[vendors[x] + 'CancelRequestAnimationFrame']
  }
  if (!window.requestAnimationFrame) window.requestAnimationFrame = function(callback, element) {
    var currTime = new Date().getTime();
    var timeToCall = Math.max(0, 16 - (currTime - lastTime));
    var id = window.setTimeout(function() {
      callback(currTime + timeToCall)
    }, timeToCall);
    lastTime = currTime + timeToCall;
    return id
  };
  if (!window.cancelAnimationFrame) window.cancelAnimationFrame = function(id) {
    clearTimeout(id)
  }
}());
(function(window) {
  "use strict";
  var utils, model, klass, view;
  utils = {
    preloadImages: function(imageUrlArray) {
      var i, img;
      for (i = 0; i < imageUrlArray.length; i += 1) {
        img = new Image();
        img.src = imageUrlArray[i]
      }
    },
    generateId: function() {
      return Math.floor(Math.random() * 10).toString() + Math.floor(Math.random() * 10).toString() + Math.floor(Math.random() * 10).toString() + Math.floor(Math.random() * 10).toString()
    },
    getRandomString: function(stringArray) {
      var output = stringArray[Math.floor(Math.random() * stringArray.length)];
      return output
    }
  };
  model = {
    logos: []
  };
  klass = {
    parameters: {},
    init: function(options) {
      this.parameters = options;
      this.loadImages(5);
      view.init();
    },
    destroy: function() {
      view.destroy();
    },
    changeImage: function(newImage) {
      view.changeImage(newImage);
    },
    changeDirection: function(xDir, yDir) {
      view.changeDirection(xDir, yDir);
    },
    loadImages: function(quantity) {
      var i;
      for (i = 0; i < quantity; i += 1) {
        model.logos.push(klass.parameters.imageUrl)
      }
      utils.preloadImages(model.logos)
    },
    getImage: function(selection) {
      var logo = '',
        logoFilename, currentImage = view.$logo.style.backgroundImage,
        currentImageUrl = currentImage.replace(/^url\(["']?/, '').replace(/["']?\)$/, ''),
          currentImageFilename = currentImageUrl.substring(currentImageUrl.lastIndexOf('/') + 1);
          console.log('currentImageUrl', currentImageUrl);

          if (selection === 'random') {
            logo = utils.getRandomString(model.logos);
            logoFilename = logo.substring(logo.lastIndexOf('/') + 1);
            if (logoFilename === currentImageFilename) {
              logo = utils.getRandomString(model.logos)
            }
          } else {
            logo = model.logos[selection + 1]
          }
          return logo
        }
  };
  view = {
    init: function() {
      var self = this;
      // document.body.style.height = '100%';
      // document.body.style.width = '100%';
      self.$container = document.createElement('div');
      self.$container.style.position = 'relative';
      self.$container.style.backgroundColor = '#000';
      self.$container.style.height = '100%';
      self.$container.style.width = '100%';
      self.$container.id = klass.parameters.uid;
      self.$container.classList.add('bounceEffect');
      document.body.appendChild(self.$container);
      self.$logo = document.createElement('div');
      self.$logo.id = 'bounce-' + utils.generateId().toString();
      self.$logo.style.position = 'absolute';
      self.$logo.style.backgroundSize = '100%';
      self.$logo.style.backgroundRepeat = 'no-repeat';
      self.imageUrl = klass.parameters.imageUrl;
      self.$logo.style.backgroundImage = 'url(' + self.imageUrl + ')'
      self.$logo.style.width = '20vh';
      self.$logo.style.height = '20vh';
      self.$container.appendChild(self.$logo);
      self.speed = klass.parameters.speed;
      self.maxSpeed = klass.parameters.maxSpeed;
      this.refreshImage();
      self.bounce(self.$logo)
    },
    destroy: function () {
      document.body.removeChild(this.$container);
      this.stop = true;
    },
    changeImage: function(newImage) {
      this.imageUrl = newImage;
      this.refreshImage();
    },
    refreshImage: function(imageUrl) {
      //todo: corner/edge detection
      this.$logo.style.backgroundImage = 'url(' + this.imageUrl + ')'
    },
    changeDirection: function(xDir, yDir) {
      var safeXDir = xDir == null || ['left','right'].indexOf(xDir) == -1 ? this.xDir : xDir;
      var safeYDir = yDir == null || ['up','down'].indexOf(yDir) == -1 ? this.yDir : yDir;
      console.log('bounce changeDirection', safeXDir, safeYDir);
      this.xDir = safeXDir;
      this.yDir = safeYDir;
    },
    bounce: function(element) {
      var self = this;
      self.elementWidth = element.offsetWidth,
      self.elementHeight = element.offsetHeight,
      self.xMax = window.innerWidth - (self.elementWidth / 10),
      self.yMax = window.innerHeight - (self.elementHeight / 10),
      self.xPos = Math.floor(Math.random() * (self.xMax - self.elementWidth)),
      self.yPos = Math.floor(Math.random() * (self.yMax - self.elementHeight)),
      self.xDir = utils.getRandomString(["right", "left"]),
      self.yDir = utils.getRandomString(["up", "down"]);
      self.stop = false;

      function move() {
        if (self.xDir === "right") {
          if (self.xPos > (self.xMax - self.elementWidth - self.speed)) {
            self.xDir = "left";
            self.refreshImage()
          }
        } else if (self.xDir === "left") {
          if (self.xPos < self.speed) {
            self.xDir = "right";
            self.refreshImage()
          }
        }
        if (self.yDir === "down") {
          if (self.yPos > (self.yMax - self.elementHeight - self.speed)) {
            self.yDir = "up";
            self.refreshImage()
          }
        } else if (self.yDir === "up") {
          if (self.yPos < self.speed) {
            self.yDir = "down";
            self.refreshImage()
          }
        }
        if (self.xDir === "right") {
          self.xPos = self.xPos + self.speed
        } else if (self.xDir === "left") {
          self.xPos = self.xPos - self.speed
        }
        if (self.yDir === "down") {
          self.yPos = self.yPos + self.speed
        } else if (self.yDir === "up") {
          self.yPos = self.yPos - self.speed
        }
        element.style.transform = 'translate3d(' + self.xPos + 'px,' + self.yPos + 'px, 0)';
        element.style.OTransform = 'translate3d(' + self.xPos + 'px,' + self.yPos + 'px, 0)';
        element.style.msTransform = 'translate3d(' + self.xPos + 'px,' + self.yPos + 'px, 0)';
        element.style.MozTransform = 'translate3d(' + self.xPos + 'px,' + self.yPos + 'px, 0)';
        element.style.WebkitTransform = 'translate3d(' + self.xPos + 'px,' + self.yPos + 'px, 0)';

        if (self.stop && self.stop == true) {
          window.cancelAnimationFrame(self.rAFId);
        } else {
          self.rAFId = window.requestAnimationFrame(move);
        }
      };
      self.rAFId = window.requestAnimationFrame(move);
    }
  };
  var bounceEffect = function(options) {
    this.init(options)
  };
  bounceEffect.prototype.init = function(options) {
    var defaultWidth = Math.floor(window.innerWidth * 0.4) > 400 ? 400 : Math.floor(window.innerWidth * 0.4),
      defaultHeight = defaultWidth / 2;
    console.log('opts', options);
    //todo: better width/height calculations
    this.parameters = {
      logoWidth: options.logoWidth || defaultWidth,
      logoHeight: options.logoHeight || defaultHeight,
      speed: options.speed || 8,
      imageUrl: options.imageUrl || 'https://static-cdn.jtvnw.net/jtv_user_pictures/53881fe2-647e-4b34-8bd0-5bf20c32c8d1-profile_image-300x300.png',
      maxSpeed: options.maxSpeed || 50,
      uid: utils.generateId()
    };
    this.create();
  };
  bounceEffect.prototype.create = function() {
    klass.init(this.parameters);
  };
  bounceEffect.prototype.destroy = function() {
    klass.destroy();
  };
  bounceEffect.prototype.changeImage = function(newImage) {
    klass.changeImage(newImage);
  };
  bounceEffect.prototype.changeDirection = function(xDir, yDir) {
    klass.changeDirection(xDir, yDir);
  };
  window.bounceEffect = bounceEffect
})(window);
