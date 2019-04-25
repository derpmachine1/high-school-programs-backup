import pygame
from time import sleep
from random import randint
import csv

pygame.init()

# General program window variables
fps_clock = pygame.time.Clock()  # Used to control fps of program
screen = pygame.display.set_mode((1000, 750))  # Create screen
pygame.display.set_caption("Landscape")  # Set window caption

# Controls the screen to be displayed
# 0 is the title screen, -1 is the death screen, 1-3 are the levels, 4 is the win screen.
level = 0

# Predefined colours
white = (250, 200, 175)
red = (200, 50, 0)
black = (50, 50, 200)
sky = (100, 150, 250)

# Predefined fonts
arial = pygame.font.Font('Arial.ttf', 100)
arial_s = pygame.font.Font('Arial.ttf', 33)

# Location of the camera
x_pos = 0
right_boundary = 0  # The coordinate where the level ends

# Location of the mouse
mouse_x = 0
mouse_y = 0
# Variable for if mouse is being left-clicked
l_click = False

# Some variables that control the agility of the player
move_speed = 0.75
jump_strength = -25
gravity = 1
friction = 0.85  # The player's speed is multiplied by this so it (hopefully) slows down


# A class that contains the player and everything it can do
class Player:
    def __init__(self):
        self.lives = 3

        # Position
        self.x = 0
        self.y = 500
        # Speeds
        self.delta_x = 0
        self.delta_y = 0

        # Size of player
        self.width = 20
        self.height = 40

        self.jumped = True  # Set to True if the player jumps, disabling jumping again until they land.

    # Reset player's position and speed
    def reset(self):
        self.x = 0
        self.y = 500
        self.delta_x = 0
        self.delta_y = 0
        self.jumped = True

    def lose_life(self):
        self.lives -= 1
        for entity in entities:
            entity.reset()
        if self.lives == 0:  # Goes to death screen if out of lives
            global level
            level = -1

    # Reset the player's lives back to 3
    def reset_lives(self):
        self.lives = 3

    def move(self):
        # Arrow keys move player
        key = pygame.key.get_pressed()
        if key[pygame.K_LEFT]:
            self.delta_x -= move_speed
        if key[pygame.K_RIGHT]:
            self.delta_x += move_speed
        if key[pygame.K_UP]:
            if not self.jumped:  # If not jumped (aka on the ground) give an initial speed boost up
                self.delta_y += jump_strength
                self.jumped = True

        # Limits player location to inside the left and right boundaries
        if self.x < 0:
            self.x = 0
            self.delta_x = 0
        if self.x + self.width > right_boundary:
            self.x = right_boundary - self.width
            self.delta_x = 0
            # Win level
            global level
            level += 1  # Moves to next level when it reaches the end
            for entity in entities:
                entity.reset()

        # Checks if player fell off the world and died
        if self.y > 1000:
            self.lose_life()

        self.delta_y += gravity  # Changes speed by gravity

        self.delta_x *= friction  # Makes speed decay
        self.delta_y *= friction

        self.x += self.delta_x  # Changes position by speed
        self.y += self.delta_y

    def draw(self):
        pygame.draw.rect(screen, red, (self.x - x_pos, self.y, self.width, self.height))  # Image drawn to the screen

    # Draws a rect object, used for collision detection
    def draw_hit_box(self):
        return pygame.Rect(self.x, self.y, self.width, self.height)  # The hitbox


# Class for AI enemies
class AI:
    def __init__(self, des_level, x_init, y_init):
        # Current movement the AI is making; 0 is nothing, 1 left, 2 right, 3 jump
        self.action = 0
        self.action_delay = 60  # Delay between actions
        self.action_timer = self.action_delay  # Counter that goes from action_delay to 0

        # If AI is alive; can be used to determine if the functions should be called
        self.alive = True

        # What level the AI should appear in
        self.des_level = des_level

        # Starting position; used when resetting level
        self.x_init = x_init
        self.y_init = y_init

        # Position
        self.x = self.x_init
        self.y = self.y_init
        # Speeds
        self.delta_x = 0
        self.delta_y = 0

        # Size of AI
        self.width = 20
        self.height = 40

        self.jumped = True  # Set to True if the AI jumps, disabling jumping again until they land.

    def reset(self):  # Resets AI, this is actually only called when the player resets
        self.x = self.x_init
        self.y = self.y_init
        self.delta_x = 0
        self.delta_y = 0
        self.action = 0
        self.alive = True

    # Makes the AI randomly decide what to do; 1 is left, 2 is right, 3 is jump
    def determine_action(self):
        if self.action_timer <= 0:
            self.action = randint(1, 3)
            self.action_timer = self.action_delay
        else:
            self.action_timer -= 1

    def move(self):
        # Movements
        if self.action == 1:
            self.delta_x -= move_speed
        if self.action == 2:
            self.delta_x += move_speed
        if self.action == 3:
            if not self.jumped:  # If not jumped (aka on the ground) give an initial speed boost up
                self.delta_y += jump_strength
                self.jumped = True

        # Limits AI location to inside the left and right boundaries
        if self.x < 0:
            self.x = 0
            self.delta_x = 0
        if self.x + self.width > right_boundary:
            self.x = right_boundary - self.width
            self.delta_x = 0

        self.delta_y += gravity  # Changes speed by gravity

        self.delta_x *= friction  # Makes speed decay
        self.delta_y *= friction

        self.x += self.delta_x  # Changes position by speed
        self.y += self.delta_y

    def draw(self):
        pygame.draw.rect(screen, black, (self.x - x_pos, self.y, self.width, self.height))  # Image drawn to the screen

    # Draws a rect object, used for collision detection
    def draw_hit_box(self):
        return pygame.Rect(self.x, self.y, self.width, self.height)  # The hit box


# Function that draws a ui element at a location
# x, y, width, height control the box size
# text for any text on the ui; always white in colour
# Title is a boolean that controls the font size
# colour for colour of box
# if is_button is True, it will activate things like clicking to change levels and changing colour when hovering over
# lvl says to what level the game will go to if the butotn is clicked; if it's not a button this number is ignored
def draw_ui(x, y, width, height, text, title, colour, is_button, lvl):
    # Draw the box
    pygame.draw.rect(screen, colour, (x, y, width, height))

    # If it is a button
    if is_button:
        # If the mouse is over it
        if x < mouse_x < x + width and y < mouse_y < y + height:
            # Create a new lighter colour and make the button that lighter colour
            hover_colour = (colour[0] + 25, colour[1] + 25, colour[2] + 25)
            pygame.draw.rect(screen, hover_colour, (x, y, width, height))
            # If left-clicked (while still hovering on the button), change the level and reset the player location
            if l_click:
                global level
                level = lvl
                for entity in entities:
                    entity.reset()
                if lvl == 0:  # If going back to main menu/title
                    player.reset_lives()  # reset the lives
                    sleep(0.2)  # Wait a bit; else the user will skip through the next button and start another game

    # Create and blit the text onto the box
    if title:
        button_text = arial.render(text, False, white)
    else:
        button_text = arial_s.render(text, False, white)
    screen.blit(button_text, (x + width / 2 - button_text.get_width() / 2, y + height / 2 - button_text.get_height() / 2))


# Draws a background onto the screen
def draw_bg():
    pygame.draw.rect(screen, sky, (0, 0, 1000, 750))


# Moves the game camera; makes the game scroll left and right
def move_camera(x):
    if x + 500 != player.x:
        x = player.x - 500

    # Limits the camera at the edges
    if x < 0:
        x = 0
    if x > right_boundary - 1000:
        x = right_boundary - 1000
    return x


# The csv files contain a lot of coordinates that represent the top-left of size 50x50 tiles
# They are put into lists of lists

with open("level_zero.csv", "r") as file:
    file_reader = csv.reader(file)
    level_zero = [row for row in file_reader]

with open("level_one.csv", "r") as file:
    file_reader = csv.reader(file)
    level_one = [row for row in file_reader]

with open("level_two.csv", "r") as file:
    file_reader = csv.reader(file)
    level_two = [row for row in file_reader]

with open("level_three.csv", "r") as file:
    file_reader = csv.reader(file)
    level_three = [row for row in file_reader]

with open("level_placeholder.csv", "r") as file:
    file_reader = csv.reader(file)
    level_placeholder = [row for row in file_reader]

# The tiles in the current level; tiles from csv files are loaded to this
current_level = []

player = Player()  # Player object
brian = AI(3, 500, 500)  # Boss

players = [player]  # List of players
ais = [brian]  # List of AIs
# List of all the entities
entities = ais + players

# Main game loop
run = True
while run:
    # Check for events
    for event in pygame.event.get():
        if event.type == pygame.QUIT:  # If user clicks quit, stop game loop
            run = False

    # The following are merely so checking for certain things is made easier by saving them to variables
    # Saves mouse position to variables that are easier to use
    mouse_x = pygame.mouse.get_pos()[0]
    mouse_y = pygame.mouse.get_pos()[1]
    # Finds mouse left click and saves to variable so it's easier to use
    if pygame.mouse.get_pressed()[0]:
        l_click = True
    else:
        l_click = False

    x_pos = move_camera(x_pos)  # Makes the screen scroll by shifting everything to keep the player in the middle

    # While unlikely, make sure the level variable doesn't go to levels that don't exist; stay between -1 and 4
    if level > 4:
        level = 4
    if level < -1:
        level = -1

    draw_bg()  # Draws background

    # Executes things specific to the level; loads the level tile coordinates (once) and draws level-specific text
    if level == 0:  # Title screen
        current_level = level_zero

        # Draw title and play button
        draw_ui(50, 50, 900, 150, "SUPERB              ", True, red, False, 0)
        draw_ui(50, 200, 900, 150, "MARK BROTHER", True, red, False, 0)
        draw_ui(50, 350, 900, 50, "VOTED #1 SOVIET GAME BY EVERYONE WHO AGREED", False, red, False, 0)
        draw_ui(350, 500, 300, 150, "PLAY", True, red, True, 1)

        # (Fake )Copyright
        draw_ui(0, 0, 700, 45, "RED STAR PRODUCTIONS 1917 PRESENTS:", False, red, False, 1)

    elif level == 1:
        current_level = level_one

        # Draw instructions
        draw_ui(50 - x_pos, 50, 900, 150, "INSTRUCTIONS", True, red, False, 0)
        draw_ui(50 - x_pos, 175, 900, 50, "BRIAN the CAPITALIST has unleashed evil upon world by", False, red, False, 0)
        draw_ui(50 - x_pos, 225, 900, 50, "replacing everything with poorly drawn obstacles.", False, red, False, 0)
        draw_ui(50 - x_pos, 275, 900, 50, "You must save the world, MARK. Use the arrow keys to move.", False, red, False, 0)
        draw_ui(50 - x_pos, 325, 900, 50, "Touch the right side of the level to advance.", False, red, False, 0)

    elif level == 2:
        current_level = level_two

    elif level == 3:
        current_level = level_three

        # Dialogue
        draw_ui(50 - x_pos, 175, 900, 50, "BRIAN the CAPITALIST: You will never defeat me!", False, red, False, 0)

    elif level == 4:
        current_level = level_placeholder

        # Win text
        draw_ui(300, 50, 400, 150, "MARK", True, red, False, 0)
        draw_ui(300, 200, 400, 150, "WON", True, red, False, 0)
        draw_ui(350, 500, 300, 150, "NICE", True, red, True, 0)

    elif level == -1:  # Death screen
        current_level = level_placeholder

        # Death text
        draw_ui(300, 50, 400, 150, "MARK", True, red, False, 0)
        draw_ui(300, 200, 400, 150, "DIED", True, red, False, 0)
        draw_ui(350, 500, 300, 150, "DARN", True, red, True, 0)

    # Draw these things except on the title screen
    if level != 0:
        draw_ui(0, 0, 150, 45, "LIVES: " + str(player.lives), False, red, False, 1)

    right_boundary = 0  # This variable is the x coordinate where the level ends; set to 0 to reset it
    # Draws the tiles
    for tile in current_level:
        tile = [int(tile[x]) for x in range(len(tile))]  # Changes coordinates from strings to ints

        pygame.draw.rect(screen, white, (tile[0] - x_pos, tile[1], 50, 50))  # Draws tile outline
        pygame.draw.rect(screen, red, (tile[0] + 1 - x_pos, tile[1] + 1, 48, 48))  # Draws tile

        # Finds the right-most limit of the map
        if tile[0] + 50 > right_boundary:
            right_boundary = tile[0] + 50

    # Executes player movements
    if player.lives > 0:
        player.move()
    # Executes AI movements
    for ai in ais:
        if ai.alive and ai.des_level == level:  # If AI is alive and should be in the current level
            ai.determine_action()
            ai.move()

    # Collision detection; uses Pygame's colliderect() function, which only works with rect objects
    # Thus, despite all the tiles and entities being drawn at this point,
    # Rect objects will be drawn on top (but not displayed)

    # For each entity, create a list of the entity itself and the hit box of it in the form of a Rect object
    hit_boxes = [[entity, entity.draw_hit_box()] for entity in entities]

    # Tile-Entity collision: Loops through the tiles and checks each tile with all the entities
    # For each tile
    for tile in current_level:
        tile = [int(tile[x]) for x in range(len(tile))]  # Changes coordinates from strings to ints
        tile_hit_box = pygame.Rect(tile[0], tile[1], 50, 50)  # Hit box of tile

        # For each entity
        for entity, hit_box in hit_boxes:
            # If it is colliding with the tile, set the entity's coordinates so it isn't and kill its speed
            if hit_box.colliderect(tile_hit_box):
                if hit_box.bottom > tile_hit_box.top > hit_box.top:  # If above tile
                    entity.y = tile_hit_box.top - entity.height - 1
                    entity.delta_y = 0
                    entity.jumped = False
                elif hit_box.right > tile_hit_box.left > hit_box.left:  # If left of tile
                    entity.x = tile_hit_box.left - entity.width
                    entity.delta_x = 0
                elif hit_box.left < tile_hit_box.right < hit_box.right:  # If right of tile
                    entity.x = tile_hit_box.right
                    entity.delta_x = 0
                elif hit_box.top < tile_hit_box.bottom < hit_box.bottom:  # If below tile
                    entity.y = tile_hit_box.bottom
                    entity.delta_y = 0

    # Entity-Entity collision: Checks each entity with each entity
    # Example: If the entities are A B and C, A checks with B and C, B checks with C, C checks with no one
    # Since the last entity checks with no-one, it simply isn't looped through
    # For each entity
    for i in range(len(hit_boxes) - 1):
        entity1 = hit_boxes[i][0]
        hit_box1 = hit_boxes[i][1]

        # If the entity in question is a dead AI, skip the collision
        if type(entity1) is AI:
            if not entity1.alive:
                break

        # For each entity after the index of the entity above
        for j in range(i + 1, len(hit_boxes)):
            entity2 = hit_boxes[j][0]
            hit_box2 = hit_boxes[j][1]
            # If entity1 is colliding with entity2, set both the coordinates and the speeds of both so they don't

            # If the entity in question is a dead AI, skip the collision
            if type(entity1) is AI:
                if not entity1.alive:
                    break

            if hit_box1.colliderect(hit_box2):
                if hit_box1.bottom > hit_box2.top > hit_box1.top:  # If 1 is above 2
                    entity1.y = hit_box2.top - entity1.height
                    entity1.delta_y = 0
                    entity1.jumped = False
                    entity2.y = hit_box1.bottom
                    entity2.delta_y = 0

                    # If a player is stepping on an AI
                    if type(entity1) is Player and type(entity2) is AI:
                        entity2.alive = False
                    # If an AI is stepping on a player
                    if type(entity1) is AI and type(entity2) is Player:
                        entity2.lose_life()

                elif hit_box1.top < hit_box2.bottom < hit_box1.bottom:  # If 1 is below 2
                    entity1.y = hit_box2.bottom
                    entity1.delta_y = 0
                    entity2.y = hit_box1.top - entity2.height
                    entity2.delta_y = 0
                    entity2.jumped = False

                    # If a player is stepping on an AI
                    if type(entity2) is Player and type(entity1) is AI:
                        entity1.alive = False
                    # If an AI is stepping on a player
                    if type(entity2) is AI and type(entity1) is Player:
                        entity1.lose_life()

                elif hit_box1.right > hit_box2.left > hit_box1.left:  # If 1 is left of 2
                    entity1.x = hit_box2.left - entity1.width
                    entity1.delta_x = 0
                    entity2.x = hit_box1.right
                    entity2.delta_x = 0
                elif hit_box1.left < hit_box2.right < hit_box1.right:  # If 1 is right of 2
                    entity1.x = hit_box2.right
                    entity1.delta_x = 0
                    entity2.x = hit_box1.left - entity2.width
                    entity2.delta_x = 0

    # Draws player
    if player.lives > 0:
        player.draw()

    # Draws AIs
    for ai in ais:
        if ai.alive and ai.des_level == level:  # If AI is alive and should be in the current level
            ai.draw()

    pygame.display.flip()
    fps_clock.tick(60)  # Sets program to 60fps

pygame.quit()  # Quit at the end
