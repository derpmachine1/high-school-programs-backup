"""
To Do:
Split UIElement class into multiple classes


"""

import pygame
from time import sleep
from random import randint
from math import sin
import csv

pygame.init()
pygame.mixer.init()

full_screen = False

# General program window variables
fps_clock = pygame.time.Clock()  # Used to control fps of program
if full_screen:  # If fullscreen, set the screen first and then obtain the size
    screen = pygame.display.set_mode((0, 0), pygame.FULLSCREEN)  # Creates full screen
    screen_w = pygame.display.get_surface().get_size()[0]  # Gets width of full screen
    screen_h = pygame.display.get_surface().get_size()[1]  # Gets height of full screen
else:  # If not fullscreen, set the size first and then set the screen
    screen_w = 1000
    screen_h = 750
    screen = pygame.display.set_mode((screen_w, screen_h))  # Creates full screen

pygame.display.set_caption("Superb Mark Brother 2: The Capitalist Strikes Back")  # Set window caption

"""
-1 - Death
0 - Title
0.1 - Singleplayer instructions
0.2 - Multiplayer instructions
0.3 - Help instructions
1-n - Corresponds to level
1.1-n.1 - Victory of corresponding level
100 - Win screen?
"""
level = 0  # Controls the screen to be displayed
options = False  # Controls if the options menu is open

# Predefined colours
white = (230, 230, 230)
red = (230, 75, 75)
black = (25, 25, 25)
sky = (75, 175, 230)

# Predefined sounds
"""none for now"""
sounds = []  # List of all sounds

# Location of the mouse
mouse_x = 0
mouse_y = 0

l_click = False  # Variable for if mouse is being left-clicked

time = 0  # Keeps time; used for period animations

counter_limit = 1000  # Max value of counter
delta_counter = 17  # Speed counter decreases
counter = counter_limit  # Set to zero when switching to new screens, used for animations


# Class that supports a rectangle with some text on top
class UIElement:
    def __init__(self, has_bg, x, y, width, height, y_offset_max, is_bobbing, colour, text, text_colour, font, font_size):
        self.has_bg = has_bg
        self.real_x = x
        self.real_y = y
        self.width = width
        self.height = height
        self.colour = colour
        # Used to shift the UI up and down for animations
        self.y_offset_max = y_offset_max
        self.y_offset_speed = 15
        self.y_offset = self.y_offset_max
        # Take real location and add offset to find location on game screen
        self.x = self.real_x
        self.y = self.real_y + self.y_offset
        # Variable to control if UI should bob up and down
        self.is_bobbing = is_bobbing

        self.text = text
        self.text_colour = text_colour
        if font == "arial":
            self.font = pygame.font.Font('assets/fonts/arial.ttf', font_size)
        elif font == "futura":
            self.font = pygame.font.Font('assets/fonts/futura.ttf', font_size)

    def draw(self):  # Draws UI
        if self.has_bg:  # If it should have a background, draw the background
            pygame.draw.rect(screen, self.colour, (self.x - self.width / 2, self.y - self.height / 2, self.width, self.height))

        # Create text image from designated text with designated font
        ui_text = self.font.render(self.text, True, self.text_colour)
        # Put the text on top of the UIElement
        screen.blit(ui_text, (self.x - ui_text.get_width() / 2, self.y - ui_text.get_height() / 2))

    def increase_offset(self):  # Move it down
        self.y_offset = min(self.y_offset + self.y_offset_speed, self.y_offset_max)

    def decrease_offset(self):  # Move it up
        self.y_offset = max(self.y_offset - self.y_offset_speed, 0)

    def calculate_coordinates(self):
        self.x = self.real_x
        if self.is_bobbing:
            self.y = self.real_y + self.y_offset + 5 * sin(time / 20)
        else:
            self.y = self.real_y + self.y_offset


# Child class of UIElement that adds button functionality
class Button(UIElement):
    def __init__(self, x, y, width, height, y_offset_max, is_bobbing, colour, text, text_colour, font, font_size, lvl):
        self.real_x = x
        self.real_y = y
        self.width = width
        self.height = height
        self.colour = colour
        # Used to shift the UI up and down for animations
        self.y_offset_max = y_offset_max
        self.y_offset_speed = 15
        self.y_offset = self.y_offset_max
        # Take real location and add offset to find location on game screen
        self.x = self.real_x
        self.y = self.real_y + self.y_offset
        # Variable to control if UI should bob up and down
        self.is_bobbing = is_bobbing

        self.text = text
        self.text_colour = text_colour
        if font == "arial":
            self.font = pygame.font.Font('assets/fonts/arial.ttf', font_size)
        elif font == "futura":
            self.font = pygame.font.Font('assets/fonts/futura.ttf', font_size)

        self.lvl = lvl

    def draw(self):  # Draws UI
        # Draw rectangle, lightened if being hovered over
        if self.x - self.width / 2 < mouse_x < self.x + self.width / 2 and self.y - self.height / 2 < mouse_y < self.y + self.height / 2:
            pygame.draw.rect(screen, (self.colour[0] + 25, self.colour[1] + 25, self.colour[2] + 25), (self.x - self.width / 2, self.y - self.height / 2, self.width, self.height))
        else:
            pygame.draw.rect(screen, self.colour, (self.x - self.width / 2, self.y - self.height / 2, self.width, self.height))

        # If left-clicked (while still hovering on the button), change the level and reset everything
        if l_click and self.x - self.width / 2 < mouse_x < self.x + self.width / 2 and self.y - self.height / 2 < mouse_y < self.y + self.height / 2:
            global level
            level = self.lvl
            reset()

        # Create text image from designated text with designated font
        ui_text = self.font.render(self.text, True, self.text_colour)
        # Put the text on top of the UIElement
        screen.blit(ui_text, (self.x - ui_text.get_width() / 2, self.y - ui_text.get_height() / 2))


# Class that supports an options button object
class OptionsButton(UIElement):
    open = False
    def draw(self):  # Draws UI
        # Draw rectangle, lightened if being hovered over
        if self.x - self.width / 2 < mouse_x < self.x + self.width / 2 and self.y - self.height / 2 < mouse_y < self.y + self.height / 2:
            pygame.draw.rect(screen, (self.colour[0] + 25, self.colour[1] + 25, self.colour[2] + 25), (self.x - self.width / 2, self.y - self.height / 2, self.width, self.height))
        else:
            pygame.draw.rect(screen, self.colour, (self.x - self.width / 2, self.y - self.height / 2, self.width, self.height))

        # If left-clicked (while still hovering on the button), change the level and reset everything
        if l_click and self.x - self.width / 2 < mouse_x < self.x + self.width / 2 and self.y - self.height / 2 < mouse_y < self.y + self.height / 2:
            if self.open:
                self.open = False
            else:
                self.open = True

        # Create text image from designated text with designated font
        ui_text = self.font.render(self.text, True, self.text_colour)
        # Put the text on top of the UIElement
        screen.blit(ui_text, (self.x - ui_text.get_width() / 2, self.y - ui_text.get_height() / 2))

        if open:  # If open, draw options screen
            self.draw_options()

    def draw_options(self):
        pass



# Draws a background onto the screen
def draw_bg():
    pygame.draw.rect(screen, sky, (0, 0, screen_w, screen_h))


# UI Objects; Titles are 72pt, subtitles are 36pt, everything else is 24pt.

options_button = OptionsButton(True, 5, 5, 20, 20, 1200, False, white, "", white, "futura", 24)

# 0
title = UIElement(False, screen_w * 0.5, screen_h * 0.1, 0, 0, screen_h + 100, True, red,
                  "Superb Mark Brother 2:", white, "futura", 72)
subtitle = UIElement(False, screen_w * 0.5, screen_h * 0.2, 0, 0, screen_h + 200, True, red,
                     "The Capitalist Strikes Back", white, "futura", 36)
play_sp = Button(screen_w * 0.5, screen_h * 0.4, 300, 50, screen_h + 400, False, red,
                 "Singleplayer", white, "futura", 24, 0.1)
play_mp = Button(screen_w * 0.5, screen_h * 0.5, 300, 50, screen_h + 500, False, red,
                 "Multiplayer (won't be implemented for at least a few months)", white, "futura", 24, 0.2)
play_h = Button(screen_w * 0.5, screen_h * 0.6, 300, 50, screen_h + 600, False, red,
                "Options", white, "futura", 24, 0.3)
dev = UIElement(False, screen_w * 0.5, screen_h - 24, 0, 0, screen_h + 800, False, red,
                "Red Star Productions 1945: All Rights Reserved by the People", white, "futura", 24)

# 0.1
sp_title = UIElement(False, screen_w * 0.5, screen_h * 0.1, 0, 0, screen_h + 100, True, red,
                     "Singleplayer", white, "futura", 72)
sp_plot1 = UIElement(True, screen_w * 0.5, screen_h * 0.5 - 120, 1000, 80, screen_h + 300, False, red,
                     "Brian the Capitalist has returned! This time, he's", white, "futura", 24)
sp_plot2 = UIElement(True, screen_w * 0.5, screen_h * 0.5 - 40, 1000, 80, screen_h + 400, False, red,
                     "brought his private organization with him! Using", white, "futura", 24)
sp_plot3 = UIElement(True, screen_w * 0.5, screen_h * 0.5 + 40, 1000, 80, screen_h + 500, False, red,
                     "paid workers, he has replaced our land with poorly", white, "futura", 24)
sp_plot4 = UIElement(True, screen_w * 0.5, screen_h * 0.5 + 120, 1000, 80, screen_h + 600, False, red,
                     "textured tiles. Mark, you must once again defeat Brian!", white, "futura", 24)
sp_button = Button(screen_w * 0.5, screen_h * 0.8, 700, 50, screen_h + 800, False, red,
                   "Communism will prevail!", white, "futura", 24, 1)

# The following lists store the assets of each level, and are updated every time the level changes
level_ui = []
level_tiles = []
level_entities = []

setting_up = True  # Set to true at the start of each level, to control things that should be run only once


# Resets everything in preparation for level switch
def reset():
    sleep(0.1)  # Wait a bit

    pygame.mixer.music.stop()  # Stops music from playing

    for sound in sounds:  # Stops all sounds from playing
        pygame.mixer.Sound.stop(sound)

    global setting_up  # Set setting up to true again
    setting_up = True


# Main game loop
running = True
while running:
    # Check for events
    for event in pygame.event.get():
        if event.type == pygame.QUIT:  # If user clicks quit, stop game loop
            running = False

    # The following are merely so checking for certain things is made easier by saving them to variables
    # Saves mouse position to variables that are easier to use
    mouse_x = pygame.mouse.get_pos()[0]
    mouse_y = pygame.mouse.get_pos()[1]
    # Finds mouse left click and saves to variable so it's easier to use
    if pygame.mouse.get_pressed()[0]:
        l_click = True
    else:
        l_click = False

    draw_bg()  # Draws background

    # Executes things general to all levels; ui, tiles
    # Draws ui
    for ui in level_ui:
        ui.decrease_offset()
        ui.calculate_coordinates()
        ui.draw()

    # Executes things specific to the level; loads the level tile coordinates (once) and draws level-specific text
    if level == 0:  # Title screen
        if setting_up:
            level_ui = [title, subtitle, play_sp, play_mp, play_h, dev]
            pygame.mixer.music.load("assets/sounds/anthem.mp3")
            pygame.mixer.music.play(-1)
    elif level == 0.1:  # Game screen
        if setting_up:
            level_ui = [sp_title, sp_plot1, sp_plot2, sp_plot3, sp_plot4, sp_button]
            pygame.mixer.music.load("assets/sounds/despacito.mp3")
            pygame.mixer.music.play(-1)
    elif level == 1:
        pass

    setting_up = False
    time += 1

    pygame.display.flip()
    fps_clock.tick(60)  # Sets program to 60fps

pygame.quit()  # Quit at the end
