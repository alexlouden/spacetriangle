
getRandom = (min, max) ->
  min + Math.floor(Math.random() * (max - min + 1))

# canvas dimensions
width = $("#game").width()
height = $("#game").height()

class SpaceShip
  velocity =
    x: 0
    y: 0
    rot: 0

  acceleration =
    x: 0
    y: 0
    rot: 0
  
  constructor: (name, width, height) ->
    @name = name
    @width = width
    @height = height
    
  makeShip: (width, height) =>
    self.ship = new Kinetic.Group()
    return
    
  float: =>
    
    # vel
    self.velocity.x += self.acceleration.x * tdiff
    self.velocity.y += self.acceleration.y * tdiff
    self.velocity.rot += self.acceleration.rot * tdiff
    
    if self.brake
      self.velocity.x *= self.BRAKE_STRENGTH # todo add tdiff as a factor
      self.velocity.y *= self.BRAKE_STRENGTH
      self.velocity.rot *= self.BRAKE_STRENGTH
    
    # pos
    self.ship.setX self.ship.getX() + self.velocity.x
    self.ship.setY self.ship.getY() + self.velocity.y
    self.ship.setRotationDeg self.ship.getRotationDeg() + self.velocity.rot
    
    # wrap
    if self.ship.getX() < -shipheight / 2
      self.ship.setX self.ship.getX() + width + 100  # left
    if self.ship.getY() < -shipheight / 2
      self.ship.setY self.ship.getY() + height + 100  # top
    if self.ship.getX() > width + shipheight
      self.ship.setX self.ship.getX() - width - 100   # right
    if self.ship.getY() > height + shipheight
      self.ship.setY self.ship.getY() - height - 100  # bottom

class Player extends SpaceObject
  forward = false
  backward = false
  left = false
  right = false
  shooting = false
  
  FWD_ACC = 4 # px/s
  ROT_ACC = 8 # deg/s
  BRAKE_STRENGTH = 0.90
  
  constructor: ->
    super("Human", 30, 50)
    
    self.makeShip(self.width, self.height)
    
    self.ship.setX width / 2
    self.ship.setY height / 2
    self.ship.setRotationDeg 180
    
  makeShip: (width, height) =>
    self.ship = new Kinetic.Group()
    
    self.ship.add new Kinetic.Polygon(
      points: [
        [       0,  height * 2/3],
        [-width/2, -height * 1/3],
        [ width/2, -height * 1/3]
      ]
      fill: "#000000"
      strokeWidth: 3
      stroke: "#ffffff"
    )
    
  keyDownHandler: (event) =>
    switch event.which
      when 38
        self.forward = true
      when 40
        self.backward = true
      when 37
        self.left = true
      when 39
        self.right = true
      when 32
        self.shooting = true
      when 88 # x
        self.brake = true
      else
        console.log event.which
    return
    
  keyUpHandler: (event) =>
    switch event.which
      when 38
        self.forward = false
      when 40
        self.backward = false
      when 37
        self.left = false
      when 39
        self.right = false
      when 32
        self.shooting = false
      when 88 # x
        self.brake = false
    return
  
  step: (tdiff) =>
    xrot = Math.cos(self.ship.getRotation() + Math.PI / 2)
    yrot = Math.sin(self.ship.getRotation() + Math.PI / 2)
    
    # acc
    if self.forward
      self.acceleration.x = self.FWD_ACC * xrot
      self.acceleration.y = self.FWD_ACC * yrot
    else if self.backward
      self.acceleration.x = -self.FWD_ACC * xrot
      self.acceleration.y = -self.FWD_ACC * yrot
    else
      self.acceleration.x = 0
      self.acceleration.y = 0
      
    if self.left
      self.acceleration.rot = -self.ROT_ACC
    else if self.right
      self.acceleration.rot = self.ROT_ACC
    else
      self.acceleration.rot = 0
    
    self.float()

window.onload = ->
  
  stage = new Kinetic.Stage(
    container: "game"
    width: width
    height: height
  )
  
  player = new Player()
  
  layer = new Kinetic.Layer()
  layer.add player.ship
  stage.add layer
  
  anim = new Kinetic.Animation((frame) ->
    tdiff = frame.timeDiff / 1000
    player.step tdiff
  , layer)
  anim.start()
  
  $(document).keydown player.keyDownHandler
  $(document).keyup player.keyUpHandler