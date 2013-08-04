
getRandom = (min, max) ->
  min + Math.floor(Math.random() * (max - min + 1))

# canvas dimensions
width = $("#game").width()
height = $("#game").height()

generate_star_group = ->
  layer = new Kinetic.Layer()
  group = new Kinetic.Group()
  
  num_stars = getRandom(100, 200)
  
  for i in [0..num_stars]
    x = Math.random() * width
    y = Math.random() * height
    size = Math.random() * 0.8
    colour = "#ffffff"
    
    glowcolour = '#ffffff'
    glowsize = Math.random() * 30
    glowamount = Math.random() * 0.8
    
    group.add new Kinetic.Circle(
      x: x
      y: y
      fillEnabled: false
      radius: size
      strokeWidth: size
      stroke: colour
      shadowColor: glowcolour
      shadowBlur: glowsize*size
      shadowOpacity: glowamount
    )
  
  layer.add group
  return layer

class SpaceShip
  
  constructor: (name, width, height) ->
    @name = name
    @width = width
    @height = height
    
    @velocity =
      x: 0
      y: 0
      rot: 0

    @acceleration =
      x: 0
      y: 0
      rot: 0
    
  makeShip: (width, height) ->
    @ship = new Kinetic.Group()
    return
    
  float: (tdiff) ->
            

class Player extends SpaceShip
  @forward = false
  @backward = false
  @left = false
  @right = false
  @shooting = false
  
  FWD_ACC = 4 # px/s
  ROT_ACC = 8 # deg/s
  BRAKE_STRENGTH = 0.90
  
  constructor: ->
    super("Human", 30, 50)
    
    @makeShip(@width, @height)
    
    @ship.setX width / 2
    @ship.setY height / 2
    @ship.setRotationDeg 180
    
  makeShip: (width, height) ->
    @ship = new Kinetic.Group()
    
    @ship.add new Kinetic.Polygon(
      points: [
        [       0,  height * 2/3],
        [-width/2, -height * 1/3],
        [ width/2, -height * 1/3]
      ]
      fill: "#000000"
      strokeWidth: 3
      stroke: "#ffffff"
    )
    
    exhaust = new Kinetic.Line(
      points: [
        [width/2, -height/3-5]
        [-width/2, -height/3-5]
      ]
      stroke: 'red'
      strokeWidth: 3
      lineCap: 'round'
      lineJoin: 'round'
    )
    @ship.add exhaust
    @ship.exhaust = exhaust
    @ship.exhaust.hide()
    
  keyDownHandler: (event) =>
    switch event.which
      when 38 then @forward = true
      when 40 then @backward = true
      when 37 then @left = true
      when 39 then @right = true
      when 32 then @shooting = true  # space
      when 88 then @brake = true     # x
      else
        console.log event.which
    return
    
  keyUpHandler: (event) =>
    switch event.which
      when 38 then @forward = false
      when 40 then @backward = false
      when 37 then @left = false
      when 39 then @right = false
      when 32 then @shooting = false
      when 88 then @brake = false
    return
  
  step: (tdiff) =>
    xrot = Math.cos(@ship.getRotation() + Math.PI / 2)
    yrot = Math.sin(@ship.getRotation() + Math.PI / 2)
    
    # acc
    if @forward
      @acceleration.x = FWD_ACC * xrot
      @acceleration.y = FWD_ACC * yrot
      @ship.exhaust.show()
    else if @backward
      @acceleration.x = -FWD_ACC * xrot
      @acceleration.y = -FWD_ACC * yrot
      @ship.exhaust.hide()
    else
      @acceleration.x = 0
      @acceleration.y = 0
      @ship.exhaust.hide()
        
    if @left
      @acceleration.rot = -ROT_ACC
    else if @right
      @acceleration.rot = ROT_ACC
    else
      @acceleration.rot = 0
    
    if @brake
      @velocity.x *= BRAKE_STRENGTH # todo add tdiff as a factor
      @velocity.y *= BRAKE_STRENGTH
      @velocity.rot *= BRAKE_STRENGTH
    
    # vel
    @velocity.x += @acceleration.x * tdiff
    @velocity.y += @acceleration.y * tdiff
    @velocity.rot += @acceleration.rot * tdiff

    # pos
    @ship.setX @ship.getX() + @velocity.x
    @ship.setY @ship.getY() + @velocity.y
    @ship.setRotationDeg @ship.getRotationDeg() + @velocity.rot

    # wrap
    if @ship.getX() < -@height / 2
      @ship.setX @ship.getX() + width + 100  # left
    if @ship.getY() < -@height / 2
      @ship.setY @ship.getY() + height + 100  # top
    if @ship.getX() > width + @height
      @ship.setX @ship.getX() - width - 100   # right
    if @ship.getY() > height + @height
      @ship.setY @ship.getY() - height - 100  # bottom
    

window.onload = ->
    
  stage = new Kinetic.Stage(
    container: "game"
    width: width
    height: height
  )
  
  player = new Player()
  
  # put player in global scope for testing
  root = exports ? this
  root.player = player
  root.anim = anim
  root.stage = stage
  
  layer = new Kinetic.Layer()
  layer.add player.ship
  stage.add layer
  
  stars = generate_star_group()
  stage.add stars
  
  anim = new Kinetic.Animation((frame) ->
    tdiff = frame.timeDiff / 1000
    player.step tdiff
  , layer)
  anim.start()
  
  $(document).keydown player.keyDownHandler
  $(document).keyup player.keyUpHandler