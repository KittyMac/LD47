# LD47

My idea for LD47 is that you are a spark of light on an interconnected network of nodes. The node you are on displays the number of moves required to get "escape the loop".  I imagine this is persistent online multiplayer.There are 4(?) teams, each separated by color.  If you move to a node where there is a light of a different color, you remove that color from the game and score your team a point.  If you find the exit (escaping the loop) you earn your team 50 points.  When you join the game, you may choose the team you join.

This is going to run on a cluster of 6 raspberry pis.

- one pi for the load balancer
- four pis for http servers
- one pi for game server

Http servers are written using Flynn.  Game server is also written in Flynn and is a remote node for all of the http servers.

# TODO:

* implement WebSocket support in Picaroon

* get basic http server running
    * serve shell http file
    * serve 

* get basic game server running
*  
