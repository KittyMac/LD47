SWIFT_BUILD_FLAGS=--configuration release

all: fix_bad_header_files build
	
fix_bad_header_files:
	-@find  . -name '._*.h' -exec rm {} \;

build:
	./meta/CombinedBuildPhases.sh
	swift build -v $(SWIFT_BUILD_FLAGS)

clean:
	rm -rf .build

test:
	swift test -v

update:
	swift package update

xcode:
	pamphlet --clean ./Resources/ ./Sources/Pamphlet/ 
	swift package generate-xcodeproj
	meta/addBuildPhase LD47.xcodeproj/project.pbxproj "LD47::LD47Framework" 'cd $${SRCROOT}; ./meta/CombinedBuildPhases.sh'


test-http: build
	.build/release/LD47 http

test-game: build
	.build/release/LD47 game 127.0.0.1:9090


install-nginx:
	sudo service nginx stop
	sudo apt-get update
	sudo apt-get install nginx
	sudo apt autoremove
	sudo rm -f /etc/nginx/sites-enabled/default
	sudo cp meta/nginx_ld47 /etc/nginx/sites-enabled/nginx_ld47
	sudo service nginx start

install-http: update build
	-sudo systemctl stop ld47_http	
	sudo cp meta/ld47_http.service /etc/systemd/system/ld47_http.service
	sudo systemctl start ld47_http
	sudo systemctl enable ld47_http
	sudo systemctl daemon-reload

install-game: update build
	-sudo systemctl stop ld47_game
	sudo cp meta/ld47_game.service /etc/systemd/system/ld47_game.service
	sudo systemctl start ld47_game
	sudo systemctl enable ld47_game
	sudo systemctl daemon-reload



uninstall-nginx:
	-sudo service nginx stop
	-sudo rm -f /etc/nginx/sites-enabled/default
	-sudo rm /etc/nginx/sites-enabled/nginx_ld47

uninstall-http:
	-sudo systemctl stop ld47_http	
	-sudo rm /etc/systemd/system/ld47_http.service

uninstall-game:
	-sudo systemctl stop ld47_game
	-sudo rm /etc/systemd/system/ld47_game.service


# ADMINISTER THE CLUSTER OVER SSH


delete-nginx:
	ssh ubuntu@192.168.1.211 "cd LD47; git checkout .; git pull; make uninstall-nginx"

delete-http1:
	ssh ubuntu@192.168.1.211 "cd LD47; git checkout .; git pull; make install-http"

delete-game1:
	ssh ubuntu@192.168.1.213 "cd LD47; git checkout .; git pull; make install-game"

delete-cluster: delete-nginx delete-http1 delete-game1



update-nginx:
	-ssh ubuntu@192.168.1.210 "git clone https://github.com/KittyMac/LD47"
	ssh ubuntu@192.168.1.210 "cd LD47; git checkout .; git pull; make install-nginx"

update-http1:
	-ssh ubuntu@192.168.1.211 "git clone https://github.com/KittyMac/LD47"
	ssh ubuntu@192.168.1.211 "cd LD47; git checkout .; git pull; make install-http"

update-game1:
	-ssh ubuntu@192.168.1.213 "git clone https://github.com/KittyMac/LD47"
	ssh ubuntu@192.168.1.213 "cd LD47; git checkout .; git pull; make install-game"

update-cluster: update-nginx update-http1 update-game1



restart-nginx:
	echo "restart nginx not yet implemented"

restart-http1:
	ssh ubuntu@192.168.1.211 "sudo systemctl restart ld47_http"

restart-game1:
	ssh ubuntu@192.168.1.213 "sudo systemctl restart ld47_game"

restart-cluster: restart-nginx restart-http1 restart-game1


status-nginx:
	echo "restart nginx not yet implemented"

status-http1:
	ssh ubuntu@192.168.1.211 "sudo systemctl status -n 300000 ld47_http"

status-game1:
	ssh ubuntu@192.168.1.213 "sudo systemctl status -n 300000 ld47_game"

