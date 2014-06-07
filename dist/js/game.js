(function() {
  var Player, SpaceShip, generate_star_group, getRandom, height, width,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  getRandom = function(min, max) {
    return min + Math.floor(Math.random() * (max - min + 1));
  };

  width = $("#game").width();

  height = $("#game").height();

  generate_star_group = function() {
    var colour, glowamount, glowcolour, glowsize, group, i, layer, num_stars, size, x, y, _i;
    layer = new Kinetic.Layer();
    group = new Kinetic.Group();
    num_stars = getRandom(100, 200);
    for (i = _i = 0; 0 <= num_stars ? _i <= num_stars : _i >= num_stars; i = 0 <= num_stars ? ++_i : --_i) {
      x = Math.random() * width;
      y = Math.random() * height;
      size = Math.random() * 0.8;
      colour = "#ffffff";
      glowcolour = '#ffffff';
      glowsize = Math.random() * 30;
      glowamount = Math.random() * 0.8;
      group.add(new Kinetic.Circle({
        x: x,
        y: y,
        fillEnabled: false,
        radius: size,
        strokeWidth: size,
        stroke: colour,
        shadowColor: glowcolour,
        shadowBlur: glowsize * size,
        shadowOpacity: glowamount
      }));
    }
    layer.add(group);
    return layer;
  };

  SpaceShip = (function() {
    function SpaceShip(name, width, height) {
      this.name = name;
      this.width = width;
      this.height = height;
      this.velocity = {
        x: 0,
        y: 0,
        rot: 0
      };
      this.acceleration = {
        x: 0,
        y: 0,
        rot: 0
      };
    }

    SpaceShip.prototype.makeShip = function(width, height) {
      this.ship = new Kinetic.Group();
    };

    SpaceShip.prototype.float = function(tdiff) {};

    return SpaceShip;

  })();

  Player = (function(_super) {
    var BRAKE_STRENGTH, FWD_ACC, ROT_ACC;

    __extends(Player, _super);

    Player.forward = false;

    Player.backward = false;

    Player.left = false;

    Player.right = false;

    Player.shooting = false;

    FWD_ACC = 4;

    ROT_ACC = 8;

    BRAKE_STRENGTH = 0.90;

    function Player() {
      this.step = __bind(this.step, this);
      this.keyUpHandler = __bind(this.keyUpHandler, this);
      this.keyDownHandler = __bind(this.keyDownHandler, this);
      Player.__super__.constructor.call(this, "Human", 30, 50);
      this.makeShip(this.width, this.height);
      this.ship.setX(width / 2);
      this.ship.setY(height / 2);
      this.ship.setRotationDeg(180);
    }

    Player.prototype.makeShip = function(width, height) {
      var exhaust;
      this.ship = new Kinetic.Group();
      this.ship.add(new Kinetic.Polygon({
        points: [[0, height * 2 / 3], [-width / 2, -height * 1 / 3], [width / 2, -height * 1 / 3]],
        fill: "#000000",
        strokeWidth: 3,
        stroke: "#ffffff"
      }));
      exhaust = new Kinetic.Line({
        points: [[width / 2, -height / 3 - 5], [-width / 2, -height / 3 - 5]],
        stroke: 'red',
        strokeWidth: 3,
        lineCap: 'round',
        lineJoin: 'round'
      });
      this.ship.add(exhaust);
      this.ship.exhaust = exhaust;
      return this.ship.exhaust.hide();
    };

    Player.prototype.keyDownHandler = function(event) {
      switch (event.which) {
        case 38:
          this.forward = true;
          break;
        case 40:
          this.backward = true;
          break;
        case 37:
          this.left = true;
          break;
        case 39:
          this.right = true;
          break;
        case 32:
          this.shooting = true;
          break;
        case 88:
          this.brake = true;
          break;
        default:
          console.log(event.which);
      }
    };

    Player.prototype.keyUpHandler = function(event) {
      switch (event.which) {
        case 38:
          this.forward = false;
          break;
        case 40:
          this.backward = false;
          break;
        case 37:
          this.left = false;
          break;
        case 39:
          this.right = false;
          break;
        case 32:
          this.shooting = false;
          break;
        case 88:
          this.brake = false;
      }
    };

    Player.prototype.step = function(tdiff) {
      var xrot, yrot;
      xrot = Math.cos(this.ship.getRotation() + Math.PI / 2);
      yrot = Math.sin(this.ship.getRotation() + Math.PI / 2);
      if (this.forward) {
        this.acceleration.x = FWD_ACC * xrot;
        this.acceleration.y = FWD_ACC * yrot;
        this.ship.exhaust.show();
      } else if (this.backward) {
        this.acceleration.x = -FWD_ACC * xrot;
        this.acceleration.y = -FWD_ACC * yrot;
        this.ship.exhaust.hide();
      } else {
        this.acceleration.x = 0;
        this.acceleration.y = 0;
        this.ship.exhaust.hide();
      }
      if (this.left) {
        this.acceleration.rot = -ROT_ACC;
      } else if (this.right) {
        this.acceleration.rot = ROT_ACC;
      } else {
        this.acceleration.rot = 0;
      }
      if (this.brake) {
        this.velocity.x *= BRAKE_STRENGTH;
        this.velocity.y *= BRAKE_STRENGTH;
        this.velocity.rot *= BRAKE_STRENGTH;
      }
      this.velocity.x += this.acceleration.x * tdiff;
      this.velocity.y += this.acceleration.y * tdiff;
      this.velocity.rot += this.acceleration.rot * tdiff;
      this.ship.setX(this.ship.getX() + this.velocity.x);
      this.ship.setY(this.ship.getY() + this.velocity.y);
      this.ship.setRotationDeg(this.ship.getRotationDeg() + this.velocity.rot);
      if (this.ship.getX() < -this.height / 2) {
        this.ship.setX(this.ship.getX() + width + 100);
      }
      if (this.ship.getY() < -this.height / 2) {
        this.ship.setY(this.ship.getY() + height + 100);
      }
      if (this.ship.getX() > width + this.height) {
        this.ship.setX(this.ship.getX() - width - 100);
      }
      if (this.ship.getY() > height + this.height) {
        return this.ship.setY(this.ship.getY() - height - 100);
      }
    };

    return Player;

  })(SpaceShip);

  window.onload = function() {
    var anim, fb, layer, player, root, stage, stars;
    fb = new Firebase('https://spacetriangle.firebaseio.com/');
    fb.child('world').on('value', function(data) {
      return console.log(data.val());
    });
    stage = new Kinetic.Stage({
      container: "game",
      width: width,
      height: height
    });
    player = new Player();
    root = typeof exports !== "undefined" && exports !== null ? exports : this;
    root.player = player;
    root.anim = anim;
    root.stage = stage;
    root.fb = fb;
    layer = new Kinetic.Layer();
    layer.add(player.ship);
    stage.add(layer);
    stars = generate_star_group();
    stage.add(stars);
    anim = new Kinetic.Animation(function(frame) {
      var tdiff;
      tdiff = frame.timeDiff / 1000;
      return player.step(tdiff);
    }, layer);
    anim.start();
    $(document).keydown(player.keyDownHandler);
    return $(document).keyup(player.keyUpHandler);
  };

}).call(this);

/*
//@ sourceMappingURL=game.js.map
*/