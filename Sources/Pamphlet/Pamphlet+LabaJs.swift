import Foundation

// swiftlint:disable all

public extension Pamphlet {
    static func LabaJs() -> String {
#if DEBUG
let filePath = "/Volumes/Development/Development/chimerasw2/LD47/Resources/laba.js"
if let contents = try? String(contentsOfFile:filePath) {
    if contents.hasPrefix("#define PAMPHLET_PREPROCESSOR") {
        do {
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/local/bin/pamphlet")
            task.arguments = ["preprocess", filePath]
            let outputPipe = Pipe()
            task.standardOutput = outputPipe
            try task.run()
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(decoding: outputData, as: UTF8.self)
            return output
        } catch {
            return "Failed to use /usr/local/bin/pamphlet to preprocess the requested file"
        }
    }
    return contents
}
return "file not found"
#else
return ###"""
/* The Labal langauge is very minimalistic. Each command is a single, non numerical character (excluding +/-). 
 * Each command can optionally be followed by a single numerical value, which makes sense only in the context of the command. For example,
 * "<120" would mean animate left 120 units.
 * 
 * x move to x position
 * y move to y position
 * 
 * < move left
 * > move right
 * ^ move up
 * v move down
 * 
 * f alpha fade
 * 
 * s uniform scale
 * 
 * r roll
 * p pitch
 * w yaw
 * 
 * d duration for current pipe
 * 
 * D staggaered duration based on sibling/child index
 * 
 * L loop (absolute) this segment (value is number of times to loop, -1 means loop infinitely)
 * 
 * l loop (relative) this segment (value is number of times to loop, -1 means loop infinitely)
 * 
 * e easing (we allow e# for shorthand or full easeInOutQuad)
 * 
 * | pipe animations (chain)
 *
 * , pipe animations with built in delay
 * 
 * ! invert an action (instead of move left, its move to current position from the right)
 * 
 * [] concurrent Laba animations ( example: [>d2][!fd1] )
 * 
 * * means a choreographed routine; the * is followed by a series of operators which represent the preprogrammed actions
 * 
 */

function StringBuilder()
{
	var strings = [];
	
	this.length = function() {
		var l = 0
		for(var i = 0; i < strings.length; i++){
			l += strings[i].length;
		}
		return l;
	}
	
	this.setLength = function(l) {
		// we need to collapse the strings, then trim
		let newString = strings.join("").substring(0, l);
		strings = [];
		strings[0] = newString;
	}
	
	this.insert = function(i, s) {
		let newString = strings.join("");
		strings = [];
		strings[0] = newString.substring(0,i);
		strings[1] = s;
		strings[2] = newString.substring(i);
	}
	
	this.delete = function(s, e) {
		let newString = strings.join("");
		strings = [];
		strings[0] = newString.substring(0,s);
		strings[1] = newString.substring(e+1);
	}

	this.append = function (string)
	{
		string = verify(string);
		if (string.length > 0) strings[strings.length] = string;
	};

	this.appendLine = function (string)
	{
		string = verify(string);
		if (this.isEmpty())
		{
			if (string.length > 0) strings[strings.length] = string;
			else return;
		}
		else strings[strings.length] = string.length > 0 ? "\r\n" + string : "\r\n";
	};

	this.clear = function () { strings = []; };

	this.isEmpty = function () { return strings.length == 0; };

	this.toString = function () { return strings.join(""); };

	var verify = function (string)
	{
		if (!defined(string)) return "";
		if (getType(string) != getType(new String())) return String(string);
		return string;
	};

	var defined = function (el)
	{
		// Changed per Ryan O'Hara's comment:
		return el != null && typeof(el) != "undefined";
	};

	var getType = function (instance)
	{
		if (!defined(instance.constructor)) throw Error("Unexpected object type");
		var type = String(instance.constructor).match(/function\s+(\w+)/);

		return defined(type) ? type[1] : "undefined";
	};
};

// requestAnimationFrame polyfill by Erik Möller
// fixes from Paul Irish and Tino Zijdel
 
(function() {
    var lastTime = 0;
    var vendors = ['ms', 'moz', 'webkit', 'o'];
    for(var x = 0; x < vendors.length && !window.requestAnimationFrame; ++x) {
        window.requestAnimationFrame = window[vendors[x]+'RequestAnimationFrame'];
        window.cancelAnimationFrame = window[vendors[x]+'CancelAnimationFrame']
                                   || window[vendors[x]+'CancelRequestAnimationFrame'];
    }
 
    if (!window.requestAnimationFrame)
        window.requestAnimationFrame = function(callback, element) {
            var currTime = new Date().getTime();
            var timeToCall = Math.max(0, 16 - (currTime - lastTime));
            var id = window.setTimeout(function() { callback(currTime + timeToCall); },
              timeToCall);
            lastTime = currTime + timeToCall;
            return id;
        };
 
    if (!window.cancelAnimationFrame)
        window.cancelAnimationFrame = function(id) {
            clearTimeout(id);
        };
}());


String.prototype.format = function() {
	a = this;
	for (k in arguments) {
		a = a.replace("{" + k + "}", arguments[k])
	}
	return a
}

Math.radians = function(degrees) {
	return degrees * Math.PI / 180;
};

Math.degrees = function(radians) {
	return radians * 180 / Math.PI;
};

function easeLinear(val) {
	let start = 0.0;
	let end = 1.0;
    return start + (end - start) * val;
}

function easeInQuad(val) {
    let start = 0.0;
    var end = 1.0;
    end -= start;
    return end * val * val + start;
}

function easeOutQuad(val) {
    let start = 0.0;
    var end = 1.0;
    end -= start;
    return -end * val * (val - 2) + start;
}

function easeInOutQuad(val) {
    let start = 0.0;
    var end = 1.0;
    val /= 0.5;
    end -= start;
    if (val < 1) return end / 2 * val * val + start;
    val--;
    return -end / 2 * (val * (val - 2) - 1) + start;
}

function easeInCubic(val) {
    let start = 0.0;
    var end = 1.0;
    end -= start;
    return end * val * val * val + start;
}

function easeOutCubic(val) {
    let start = 0.0;
    var end = 1.0;
    val--;
    end -= start;
    return end * (val * val * val + 1) + start;
}

function easeInOutCubic(val) {
    let start = 0.0;
    var end = 1.0;
    val /= 0.5;
    end -= start;
    if (val < 1) return end / 2 * val * val * val + start;
    val -= 2;
    return end / 2 * (val * val * val + 2) + start;
}


function easeInQuart(val) {
    let start = 0.0;
    var end = 1.0;
    end -= start;
    return end * val * val * val * val + start;
}

function easeOutQuart(val) {
    let start = 0.0;
    var end = 1.0;
    val--;
    end -= start;
    return -end * (val * val * val * val - 1) + start;
}

function easeInOutQuart(val) {
    let start = 0.0;
    var end = 1.0;
    val /= 0.5;
    end -= start;
    if (val < 1) return end / 2 * val * val * val * val + start;
    val -= 2;
    return -end / 2 * (val * val * val * val - 2) + start;
}


function easeInQuint(val) {
    let start = 0.0;
    var end = 1.0;
    end -= start;
    return end * val * val * val * val * val + start;
}

function easeOutQuint(val) {
    let start = 0.0;
    var end = 1.0;
    val--;
    end -= start;
    return end * (val * val * val * val * val + 1) + start;
}

function easeInOutQuint(val) {
    let start = 0.0;
    var end = 1.0;
    val /= 0.5;
    end -= start;
    if (val < 1) return end / 2 * val * val * val * val * val + start;
    val -= 2;
    return end / 2 * (val * val * val * val * val + 2) + start;
}



function easeInSine(val) {
    let start = 0.0;
    var end = 1.0;
    end -= start;
    return -end * Math.cos(val / 1 * (Math.PI / 2)) + end + start;
}

function easeOutSine(val) {
    let start = 0.0;
    var end = 1.0;
    end -= start;
    return end * Math.sin(val / 1 * (Math.PI / 2)) + start;
}

function easeInOutSine(val) {
    let start = 0.0;
    var end = 1.0;
    end -= start;
    return -end / 2 * (Math.cos(Math.PI * val / 1) - 1) + start;
}



function easeInExpo(val) {
    let start = 0.0;
    var end = 1.0;
    end -= start;
    return end * Math.pow(2, 10 * (val / 1 - 1)) + start;
}

function easeOutExpo(val) {
    let start = 0.0;
    var end = 1.0;
    end -= start;
    return end * (-Math.pow(2, -10 * val / 1) + 1) + start;
}

function easeInOutExpo(val) {
    let start = 0.0;
    var end = 1.0;
    val /= 0.5;
    end -= start;
    if (val < 1) return end / 2 * Math.pow(2, 10 * (val - 1)) + start;
    val--;
    return end / 2 * (-Math.pow(2, -10 * val) + 2) + start;
}




function easeInCirc(val) {
    let start = 0.0;
    var end = 1.0;
    end -= start;
    return -end * (Math.sqrt(1 - val * val) - 1) + start;
}

function easeOutCirc(val) {
    let start = 0.0;
    var end = 1.0;
    val--;
    end -= start;
    return end * Math.sqrt(1 - val * val) + start;
}

function easeInOutCirc(val) {
    let start = 0.0;
    var end = 1.0;
    val /= 0.5;
    end -= start;
    if (val < 1) return -end / 2 * (Math.sqrt(1 - val * val) - 1) + start;
    val -= 2;
    return end / 2 * (Math.sqrt(1 - val * val) + 1) + start;
}

function easeOutBounce(p) {
  	if (p < (4 / 11.0)) {
  		return ((121.0 * p) * p) / 16.0
    } else if (p < (8.0 / 11.0)) {
  		return (((363.0 / 40.0) * p * p) - ((99.0 / 10.0) * p)) + (17.0 / 5.0)
    } else if (p < (9.0 / 10.0)) {
  		return (((4356.0 / 361.0) * p * p) - ((35442.0 / 1805.0) * p)) + (16061.0 / 1805.0)
    } else {
  		return (((54.0 / 5.0) * p * p) - ((513.0 / 25.0) * p)) + (268.0 / 25.0)
    }
}

function easeInBounce(val) {
	return 1.0 - easeOutBounce(1.0 - val)
}

function easeInOutBounce(val){
  	if (val < 0.5) {
  		return (0.5 * easeInBounce(val * 2.0))
    } else {
  		return (0.5 * easeOutBounce((val * 2.0) - 1.0)) + 0.5
    }
}

function easeShake(val){
	return (Math.sin(val * 3.14 * 6 + 0.785) - 0.5) * (1.0 - val)
}

class _LabaTimer {

    update(timestamp) {
		
		var localThis = this;
		
        var currentTime = performance.now();
        var t = (currentTime - this.startTime) / (this.endTime - this.startTime);
        if (this.endTime == this.startTime) {
        	t = 1.0;
		}
		
		//console.log("{0}   {1}   {2}   {3}".format(this.startTime, this.endTime, currentTime, t))
        if (t >= 1.0) {
            this.action(1.0, false);

            if (this.loopCount == -1) {
                this.action(0.0, true);
		        this.startTime = performance.now();
				this.endTime = this.startTime + this.duration * 1000
                window.requestAnimationFrame(function(timestamp) {
		        	localThis.update(timestamp);
		        });
                return;
            }
            if (this.loopCount > 1) {
                this.loopCount--;
                this.action(0.0, true);
		        this.startTime = performance.now();
				this.endTime = this.startTime + this.duration * 1000
                window.requestAnimationFrame(function(timestamp) {
		        	localThis.update(timestamp);
		        });
                return;
            }

            if (this.onComplete != null) {
                this.onComplete();
            }
			
            return;
        }
		
		if (this.onUpdate != null) {
			var easingAction = this.action.easing;
			if (easingAction == null) {
				easingAction = easeInOutQuad;
			}
			this.onUpdate(easingAction(t));
		}
		
        this.action(t, false);
        window.requestAnimationFrame(function(timestamp) {
        	localThis.update(timestamp);
		});
    }

    // Simple timer class to replace the one method we used from LeanTween
    constructor(elem, act, startVal, endVal, dura, onUpdate, onComplete, loops) {

        this.view = elem;
		this.loopCount = loops;
		this.action = act;
		this.duration = dura;
		this.onComplete = onComplete;
		this.onUpdate = onUpdate;
        this.startTime = performance.now();
		this.endTime = this.startTime + this.duration * 1000

        this.action(0.0, true);
	    this.update(0);
    }
}

class _LabaAction {
	
	constructor(laba, operatorChar, elem, inverse, rawValue, easing, easingName) {
		
		this.operatorChar = operatorChar;
		this.elem = elem;
		this.inverse = inverse;
		this.rawValue = rawValue;
		this.easing = easing;
		this.easingName = easingName;

		this.action = laba.PerformActions[operatorChar];
		this._describe = laba.DescribeActions[operatorChar];
		this._init = laba.InitActions[operatorChar];
		
		if(this.inverse == false){
			this.fromValue = 0.0;
			this.toValue = 1.0;
		}else{
			this.fromValue = 1.0;
			this.toValue = 0.0;
		}
		
		if(this._init != null){
            this._init(this);
		}
	}
	
	reset(laba) {
		if (this._init != null) {
			var tempAction = new _LabaAction (laba, this.operatorChar, this.elem, this.inverse, this.rawValue, this.easing, this.easingName);
			this.fromValue = tempAction.fromValue;
			this.toValue = tempAction.toValue;
			return true;
		}
		return false;
	}

	perform(v) {
		if (this.action != null) {
			//console.log("this.easing: " + this.easingName)
			this.action (this.elem, this.fromValue + (this.toValue - this.fromValue) * this.easing(v), this);
			return true;
		}
		return false;
	}

	describe(sb) {
		if (this._describe != null) {
			this._describe (sb, this);
			return true;
		}
		return false;
	}
}


class _Laba {
	
	isOperator(c) {
        if (c == ',' || c == '|' || c == '!' || c == 'e') {
            return true;
        }
        return (c in this.InitActions);
    }

    isNumber(c) {
        return (c == '+' || c == '-' || c == '0' || c == '1' || c == '2' || c == '3' || c == '4' || c == '5' || c == '6' || c == '7' || c == '8' || c == '9' || c == '.');
    }
	
    
	
	parseAnimationString(elem, charString) {
		var idx = 0;

		var currentPipeIdx = 0;
		var currentActionIdx = 0;
        var easingAction = this.allEasings [3]; // easeInOutQuad
		var easingName = this.allEasingsByName [3];
		
		var combinedActions = []
		for(var i=0;i<this.kMaxPipes;i++){
			combinedActions[i] = []
			for(var j=0;j<this.kMaxActions;j++){
				combinedActions[i][j] = null
			}
		}

		while (idx < charString.length) {

			var invertNextOperator = false;
			var action = ' ';

			// find the next operator
			while (idx < charString.length) {
				var c = charString [idx];
				if (this.isOperator (c)) {
					if (c == '!') {
						invertNextOperator = true;
					} else if (c == '|') {
						currentPipeIdx++;
						currentActionIdx = 0;
                    } else if (c == ',') {
					    if (currentActionIdx != 0) {
                            currentPipeIdx++;
                            currentActionIdx = 0;
                        }
						
                        combinedActions [currentPipeIdx][currentActionIdx] = new _LabaAction (this, 'd', elem, false, this.kDefaultDuration * 0.26, easingAction, easingName);
                        currentPipeIdx++;
                        currentActionIdx = 0;
                    } else {
						action = c;
						idx++;
						break;
					}
				}
				idx++;
			}

			// skip anything not important
			while (idx < charString.length && !this.isNumber (charString [idx]) && !this.isOperator (charString [idx])) {
				idx++;
			}

			var value = this.LabaDefaultValue;

			// if this is a number read it in
			if (idx < charString.length && this.isNumber (charString [idx])) {
				
				// read in numerical value (if it exists)
				var isNegativeNumber = false;
				if (charString [idx] == '+') {
					idx++;
				} else if (charString [idx] == '-') {
					isNegativeNumber = true;
					idx++;
				}

				value = 0.0;

                var fractionalPart = false;
				var fractionalValue = 10.0;
				while (idx < charString.length) {
					var c = charString [idx];
					if (this.isNumber (c)) {
						if (c >= '0' && c <= '9') {
							if (fractionalPart) {
								value = value + (c - '0') / fractionalValue;
								fractionalValue *= 10.0;
							} else {
								value = value * 10 + (c - '0');
							}
						}
						if (c == '.') {
							fractionalPart = true;
						}
					}
					if (this.isOperator (c)) {
						break;
					}
					idx++;
				}

				if (isNegativeNumber) {
					value *= -1.0;
				}
			}


			// execute the action?
			if (action != ' ') {
				if (action in this.InitActions) {
					//console.log("[{0},{1}] action: {2} value: {3} inverted: {4}".format(currentPipeIdx, currentActionIdx, action, value, invertNextOperator));
					combinedActions [currentPipeIdx][currentActionIdx] = new _LabaAction (this, action, elem, invertNextOperator, value, easingAction, easingName);
					currentActionIdx++;
				} else {
					if (action == 'e') {
						var easingIdx = (value);
						if (easingIdx >= 0 && idx < this.allEasings.length) {
							easingAction = this.allEasings [easingIdx];
							easingName = this.allEasingsByName [easingIdx];
						}
					}
				}
			}

		}

		return combinedActions;
	}
	
	animateOne(elem, animationString, onUpdate, onComplete) {
		var localThis = this;
		var actionList = this.parseAnimationString (elem, animationString);
		var durationAction1 = this.PerformActions['d'];
		var durationAction2 = this.PerformActions['D'];
		var loopAction1 = this.PerformActions['L'];
		var loopAction2 = this.PerformActions['l'];
		
		var numOfPipes = 0;

		var duration = 0.0;
		var looping = 1.0;
		var loopingRelative = false;
		for (var i = 0; i < this.kMaxPipes; i++) {
			if (actionList [i][0] != null) {
				numOfPipes++;

				var durationForPipe = this.kDefaultDuration;
				for (var j = 0; j < this.kMaxActions; j++) {
                    if(actionList [i][j] != null) {
                        if (actionList[i][j].action == durationAction1 || actionList[i][j].action == durationAction2) {
                            durationForPipe = actionList[i][j].fromValue;
                        }
                        if (actionList[i][j].action == loopAction1) {
                            looping = actionList[i][j].fromValue;
                        }
                        if (actionList[i][j].action == loopAction2) {
                            loopingRelative = true;
                            looping = actionList[i][j].fromValue;
                        }
                    }
				}
				duration += durationForPipe;
			}
		}

		// having only a single pipe makes things much more efficient, so treat it separately
		if (numOfPipes == 1) {

			if (loopingRelative) {
                new _LabaTimer(elem, function (fv,f) {
                    if (f == true) {
                        for (var j = 0; j < localThis.kMaxActions; j++) {
                            if (actionList [0][j] != null && !actionList [0][j].reset (localThis)) {
                                break;
                            }
                        }
                    }
                    for (var i = 0; i < localThis.kMaxActions; i++) {
                        if (actionList [0][i] != null && !actionList [0][i].perform (fv)) {
                            break;
                        }
                    }
                }, 0.0, 1.0, duration, onUpdate, onComplete, looping);
			} else {
				for (var j = 0; j < localThis.kMaxActions; j++) {
					if (actionList [0][j] != null && !actionList [0][j].reset (localThis)) {
						break;
					}
				}
                new _LabaTimer (elem, function (fv,f) {
					for (var i = 0; i < localThis.kMaxActions; i++) {
						if (actionList [0][i] != null && !actionList [0][i].perform (fv)) {
							break;
						}
					}
				}, 0.0, 1.0, duration * localThis.kTimeScale, onUpdate, onComplete, looping);
			}
		} else {
			
			var nextAction = null;
			for (var pipeIdx = numOfPipes - 1; pipeIdx >= 0; pipeIdx--) {

				var durationForPipe = this.kDefaultDuration;
				var loopingForPipe = 1.0;
				var loopingRelativeForPipe = false;
				for (var j = 0; j < this.kMaxActions; j++) {
				    if (actionList [pipeIdx][j] != null) {						
                        if (actionList[pipeIdx][j].action == durationAction1 || actionList[pipeIdx][j].action == durationAction2) {
                            durationForPipe = actionList[pipeIdx][j].fromValue;
                        }
                        if (actionList[pipeIdx][j].action == loopAction1) {
                            loopingForPipe = actionList[pipeIdx][j].fromValue;
                        }
                        if (actionList[pipeIdx][j].action == loopAction2) {
                            loopingRelativeForPipe = true;
                            loopingForPipe = actionList[pipeIdx][j].fromValue;
                        }
                    }
				}
				
				let idx = pipeIdx;
                var localNextAction = nextAction;
				if (localNextAction == null) {
					localNextAction = onComplete;
				}
				if (localNextAction == null) {
					localNextAction = function () { return null; };
				}


				let loopingRelativeForPipeFinal = loopingRelativeForPipe;
				let durationForPipeFinal = durationForPipe;
				let loopingForPipeFinal = loopingForPipe;
				let localNextActionFinal = localNextAction;

				nextAction = function () {

					if (loopingRelativeForPipeFinal) {
                        new _LabaTimer (elem, function (fv,f) {
							if (f == true) {
								for (var j = 0; j < localThis.kMaxActions; j++) {
									if (actionList [idx][j] != null && !actionList [idx][j].reset (localThis)) {
										break;
									}
								}
							}
							for (var j = 0; j < localThis.kMaxActions; j++) {
								if (actionList [idx][j] != null && !actionList [idx][j].perform (fv)) {
									break;
								}
							}
						}, 0.0, 1.0, durationForPipeFinal, onUpdate, localNextActionFinal, loopingForPipeFinal);
					} else {
						for (var j = 0; j < localThis.kMaxActions; j++) {
							if (actionList [idx][j] != null && !actionList [idx][j].reset (localThis)) {
								break;
							}
						}
                        new _LabaTimer (elem, function (fv,f) {
							for (var j = 0; j < localThis.kMaxActions; j++) {
								if (actionList [idx][j] != null && !actionList [idx][j].perform (fv)) {
									break;
								}
							}
						}, 0.0, 1.0, durationForPipeFinal * localThis.kTimeScale, onUpdate, localNextActionFinal, loopingForPipeFinal);
					}
				};
			}

			if (nextAction != null) {
				nextAction ();
			} else {
				if (onComplete != null) {
					onComplete ();
				}
			}

		}
	}
	
	
	reset(elem) {
		if (elem.labaTransformX == undefined){
			let localElem = elem;
			localElem.labaResetElemVars = function() {
				localElem.labaTransformX = 0;
				localElem.labaTransformY = 0;
				localElem.labaTransformZ = 0;
				localElem.labaRotationX = 0;
				localElem.labaRotationY = 0;
				localElem.labaRotationZ = 0;
				localElem.labaScale = 1;

				localElem.labaAlpha = parseFloat(localElem.style.opacity);
				if (isNaN(localElem.labaAlpha)) {
					localElem.labaAlpha = 1;
				}
			}		
			localElem.labaCommitElemVars = function() {
				if (localElem.style == undefined) {
					// assume this is a pixijs object
					localElem.position.set(localElem.labaTransformX, localElem.labaTransformY);
					localElem.scale.set(localElem.labaScale, localElem.labaScale);
					localElem.rotation = localElem.labaRotationZ;
					localElem.alpha = localElem.labaAlpha;
				} else {
					var mat = Matrix.identity()				
					mat = Matrix.multiply(mat, Matrix.translate(localElem.labaTransformX, localElem.labaTransformY, localElem.labaTransformZ))
					mat = Matrix.multiply(mat, Matrix.rotateX(Math.radians(localElem.labaRotationX)))
					mat = Matrix.multiply(mat, Matrix.rotateY(Math.radians(localElem.labaRotationY)))
					mat = Matrix.multiply(mat, Matrix.rotateZ(Math.radians(localElem.labaRotationZ)))
					mat = Matrix.multiply(mat, Matrix.scale(localElem.labaScale, localElem.labaScale, localElem.labaScale))
			
					let matString = "perspective(500px) matrix3d({0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15})".format(mat.m00,mat.m10,mat.m20,mat.m30,mat.m01,mat.m11,mat.m21,mat.m31,mat.m02,mat.m12,mat.m22,mat.m32,mat.m03,mat.m13,mat.m23,mat.m33)
					
					localElem.style["webkitTransform"] = matString;
					localElem.style["MozTransform"] = matString;
					localElem.style["msTransform"] = matString;
					localElem.style["OTransform"] = matString;
					localElem.style["transform"] = matString;
			
					localElem.style["opacity"] = localElem.labaAlpha;
				}
			}
		}
		
		elem.labaResetElemVars()
		if (elem.style == undefined) {
			elem.labaTransformX = elem.position.x;
			elem.labaTransformY = elem.position.y;
			elem.labaRotationZ = elem.rotation;
			elem.labaScale = elem.scale.x;
			elem.labaAlpha = elem.alpha;
		}
	}

	animate(elem, animationString, onUpdate, onComplete) {
		
		// we utilize memory storage on the element to store our animatable variables
		if (elem.labaTransformX == undefined){
			this.reset(elem)
		}
	
		if (animationString.includes ("[")) {
			var parts = animationString.replace ('[', ' ').split ("]");
			for (var i = 0; i < parts.length; i++) {
				var part = parts[i];
				if (part.length > 0) {
					this.animateOne (elem, part, onUpdate, onComplete);
					onComplete = null;
				}
			}
		} else {
			this.animateOne (elem, animationString, onUpdate, onComplete);
			onComplete = null;
		}
	}
	
	
	
	
	
	
	
	describeOne(elem, animationString, sb) {
		var actionList = this.parseAnimationString (elem, animationString);
		var durationAction1 = this.PerformActions['d'];
		var durationAction2 = this.PerformActions['D'];
		var loopingAction1 = this.PerformActions['L'];
		var loopingAction2 = this.PerformActions['l'];

		var numOfPipes = 0;

		var duration = 0.0;
		var looping = 1;
		var loopingRelative = "absolute";
		for (var i = 0; i < this.kMaxPipes; i++) {
			if (actionList [i][0] != null) {
				numOfPipes++;

				var durationForPipe = this.kDefaultDuration;
				for (var j = 0; j < this.kMaxActions; j++) {
				    if(actionList [i][j] != null) {
                        if (actionList[i][j].action == durationAction1 || actionList[i][j].action == durationAction2) {
                            durationForPipe = actionList[i][j].fromValue;
                        }
                        if (actionList[i][j].action == loopingAction1) {
                            looping =  actionList[i][j].fromValue;
                        }
                        if (actionList[i][j].action == loopingAction2) {
                            looping =  actionList[i][j].fromValue;
                            loopingRelative = "relative";
                        }
                    }
				}
				duration += durationForPipe;
			}
		}

		// having only a single pipe makes things much more efficient, so treat it separately
		if (numOfPipes == 1) {
			var stringLengthBefore = sb.length();
			
			for (var i = 0; i < this.kMaxActions; i++) {
				if (actionList [0][i] != null && !actionList [0][i].describe (sb)) {
					break;
				}
			}


			if (looping > 1) {
				sb.append (" {0} repeating {1} times, ".format(loopingRelative, looping));
			} else if (looping == -1) {
				sb.append (" {0} repeating forever, ".format(loopingRelative));
			}

			if (stringLengthBefore != sb.length()) {
				sb.append (" {0}  ".format(actionList [0][0].easingName));

				sb.setLength(sb.length() - 2);
				if (duration == 0.0) {
					sb.append (" instantly.");
				} else {
					sb.append (" over {0} seconds.".format(duration * this.kTimeScale));
				}
			} else {
				if (sb.length() > 2) {
                    sb.setLength(sb.length() - 2);
				}
				sb.append (" wait for {0} seconds.".format(duration * this.kTimeScale));
			}

		} else {

			for (var pipeIdx = 0; pipeIdx < numOfPipes; pipeIdx++) {
				var stringLengthBefore = sb.length();

				var durationForPipe = this.kDefaultDuration;
				var loopingForPipe = 1;
				var loopingRelativeForPipe = "absolute";
				for (var j = 0; j < this.kMaxActions; j++) {
				    if (actionList [pipeIdx][j] != null) {
                        if (actionList[pipeIdx][j].action == durationAction1 || actionList[pipeIdx][j].action == durationAction2) {
                            durationForPipe = actionList[pipeIdx][j].fromValue;
                        }
                        if (actionList[pipeIdx][j].action == loopingAction1) {
                            loopingForPipe =  actionList[pipeIdx][j].fromValue;
                        }
                        if (actionList[pipeIdx][j].action == loopingAction2) {
                            loopingForPipe =  actionList[pipeIdx][j].fromValue;
                            loopingRelativeForPipe = "relative";
                        }
                    }
				}

				var idx = pipeIdx;
				for (var j = 0; j < this.kMaxActions; j++) {
					if (actionList [idx][j] != null && !actionList [idx][j].reset (this)) {
						break;
					}
				}

				for (var j = 0; j < this.kMaxActions; j++) {
					if (actionList [idx][j] != null && !actionList [idx][j].describe (sb)) {
						break;
					}
				}

				if (loopingForPipe > 1) {
					sb.append (" {0} repeating {1} times, ".format(loopingRelativeForPipe, loopingForPipe));
				} else if (loopingForPipe == -1) {
					sb.append (" {0} repeating forever, ".format(loopingRelativeForPipe));
				}

				if (stringLengthBefore != sb.length()) {
					sb.append (" {0}  ".format(actionList [idx][0].easingName));

					sb.setLength(sb.length() - 2);
					if (durationForPipe == 0.0) {
						sb.append (" instantly.");
					} else {
						sb.append (" over {0} seconds.".format(durationForPipe * this.kTimeScale));
					}
				} else {
					sb.append (" wait for {0} seconds.".format(durationForPipe * this.kTimeScale));
				}

				if (pipeIdx + 1 < numOfPipes) {
					sb.append (" Once complete then  ");
				}
			}
		}
	}

	describe(elem, animationString) {
		if (animationString == null || animationString.length == 0) {
			return "do nothing";
		}

		var sb = new StringBuilder ();
		
		if (animationString.includes ("[")) {
			var parts = animationString.replace ('[', ' ').split ("]");
			var animNumber = 0;
			sb.append ("Perform a series of animations at the same time.\n");
			for (var i = 0; i < parts.length; i++) {
				var part = parts[i];
				if (part.length > 0) {
					sb.append ("Animation #{0} will ".format(animNumber+1));
					this.describeOne (elem, part, sb);
					sb.append ("\n");
					animNumber++;
				}
			}
		} else {
			this.describeOne (elem, animationString, sb);
		}
			
		if (sb.length() > 0) {
			// upper case the starting letter
			sb.insert (0, sb.toString ().substring (0, 1).toUpperCase ());
			sb.delete(1,1);
		}

		return sb.toString ();
	}
	
	
	
	
	registerOperation(charOperator, initFunc, performFunc, describeFunc){
		this.InitActions[charOperator] = initFunc
		this.PerformActions[charOperator] = performFunc
		this.DescribeActions[charOperator] = describeFunc
	}
	
	constructor() {
		this.allEasings = [
			easeLinear,			// 0
			easeInQuad,			// 1
			easeOutQuad,		// 2
			easeInOutQuad,		// 3
			easeInCubic,		// 4
			easeOutCubic,		// 5
			easeInOutCubic,		// 6
			easeInQuart,		// 7
			easeOutQuart,		// 8
			easeInOutQuart,		// 9
			easeInQuint,		// 10
			easeOutQuint,		// 11
			easeInOutQuint,		// 12
			easeInSine,			// 13
			easeOutSine,		// 14
			easeInOutSine,		// 15
			easeInExpo,			// 16
			easeOutExpo,		// 17
			easeInOutExpo,		// 18
			easeInCirc,			// 19
			easeOutCirc,		// 20
			easeInOutCirc,		// 21
			easeInBounce,		// 22
			easeOutBounce,		// 23
			easeInOutBounce,	// 24
			easeShake			// 25
		]

		this.allEasingsByName = [
	            "ease linear", "ease out quad", "ease in quad", "ease in/out quad", "ease in cubic", "ease out cubic", "ease in/out cubic", "ease in quart", "ease out quart", "ease in/out quart",
	            "ease in quint", "ease out quint", "ease in/out quint", "ease in sine", "eas out sine", "ease in/out sine", "ease in expo", "ease out expo", "ease in out expo", "ease in circ", "ease out circ", "ease in/out circ",
	            "ease in bounce", "ease out bounce", "ease in/out bounce", "ease shake"
	    ]

		this.LabaDefaultValue = Number.MIN_VALUE;
		
		this.InitActions = {};
		this.PerformActions = {};
		this.DescribeActions = {};

		this.kMaxPipes = 40;
		this.kMaxActions = 40;
		this.kDefaultDuration = 0.57;
		this.kTimeScale = 1.0;
		
		let LabaDefaultValueFinal = this.LabaDefaultValue
		let LabaDefaultDuration = this.kDefaultDuration
		
		this.registerOperation(
				'L',
				function (newAction) {
                    if (newAction.rawValue == LabaDefaultValueFinal) {
                        newAction.rawValue = -1.0;
                    }
                    newAction.fromValue = newAction.toValue = newAction.rawValue;
                    return newAction;
                },
                function (rt, v, action) { return null; },
                function (sb, action) { return null; }
        );
		
        this.registerOperation(
                'l',
                function (newAction) {
                    if (newAction.rawValue == LabaDefaultValueFinal) {
                        newAction.rawValue = -1.0;
                    }
                    newAction.fromValue = newAction.toValue = newAction.rawValue;
                    return newAction;
                },
                function (rt, v, action) { return null; },
                function (sb, action) { return null; }
        );

        this.registerOperation(
                'd',
                function (newAction) {
                    if (newAction.rawValue == LabaDefaultValueFinal) {
                        newAction.rawValue = LabaDefaultDuration;
                    }
                    newAction.fromValue = newAction.toValue = newAction.rawValue;
                    return newAction;
                },
                function (rt, v, action) { return null; },
                function (sb, action) { return null; }
        );

        this.registerOperation(
                'D',
                function (newAction) {
                    if (newAction.rawValue == LabaDefaultValueFinal) {
                        newAction.rawValue = LabaDefaultDuration;
                    }
										
					var childIdx = 0;
					var child = newAction.elem;
					while( (child = child.previousSibling) != null ) 
					  childIdx++;
					
                    newAction.fromValue = newAction.toValue = newAction.rawValue * childIdx;
                    return newAction;
                },
                function (rt, v, action) { return null; },
                function (sb, action) { return null; }
        );

        this.registerOperation(
                'x',
                function (newAction) {
                    if (newAction.rawValue == LabaDefaultValueFinal) {
                        newAction.rawValue = 0.0;
                    }
                    if(!newAction.inverse){
                        newAction.fromValue = newAction.elem.labaTransformX;
                        newAction.toValue = newAction.rawValue;
                    }else{
                        newAction.fromValue = newAction.rawValue;
                        newAction.toValue = newAction.elem.labaTransformX;
                    }
                    return newAction;
                },
                function (elem, v, action) {
					elem.labaTransformX = v;
					elem.labaCommitElemVars();
                },
                function (sb, action) {
                    if (!action.inverse ) {
                        sb.append("move to {0} x pos, ".format(action.rawValue));
                    } else {
                        sb.append("move from {0} x pos, ".format(action.rawValue));
                    }
                }
        );


        this.registerOperation(
                'y',
                function (newAction) {
                    if (newAction.rawValue == LabaDefaultValueFinal) {
                        newAction.rawValue = 0.0;
                    }
                    if(!newAction.inverse){
                        newAction.fromValue = newAction.elem.labaTransformY;
                        newAction.toValue = newAction.rawValue;
                    }else{
                        newAction.fromValue = newAction.rawValue;
                        newAction.toValue = newAction.elem.labaTransformY;
                    }
                    return newAction;
                },
                function (elem, v, action) {
					elem.labaTransformY = v;
					elem.labaCommitElemVars();
                },
                function (sb, action) {
                    if(!action.inverse ) {
                        sb.append("move to {0} y pos, ".format(action.rawValue));
                    } else {
                        sb.append("move from {0} y pos, ".format(action.rawValue));
                    }
                    return null;
                }
        );
		
        this.registerOperation(
                'z',
                function (newAction) {
                    if (newAction.rawValue == LabaDefaultValueFinal) {
                        newAction.rawValue = 0.0;
                    }
                    if(!newAction.inverse){
                        newAction.fromValue = newAction.elem.labaTransformZ;
                        newAction.toValue = newAction.rawValue;
                    }else{
                        newAction.fromValue = newAction.rawValue;
                        newAction.toValue = newAction.elem.labaTransformZ;
                    }
                    return newAction;
                },
                function (elem, v, action) {
					elem.labaTransformZ = v;
					elem.labaCommitElemVars();
                },
                function (sb, action) {
                    if(!action.inverse ) {
                        sb.append("move to {0} z pos, ".format(action.rawValue));
                    } else {
                        sb.append("move from {0} z pos, ".format(action.rawValue));
                    }
                    return null;
                }
        );
		
        this.registerOperation(
                '<',
                function (newAction) {
                    if (newAction.rawValue == LabaDefaultValueFinal) {
                        newAction.rawValue = newAction.elem.offsetWidth;
                    }
                    if(!newAction.inverse){
                        newAction.fromValue = newAction.elem.labaTransformX;
                        newAction.toValue = newAction.elem.labaTransformX - newAction.rawValue;
                    }else{
                        newAction.fromValue = newAction.elem.labaTransformX + newAction.rawValue;
                        newAction.toValue = newAction.elem.labaTransformX;
                    }
                    return newAction;
                },
                function (elem, v, action) {
					elem.labaTransformX = v
					elem.labaCommitElemVars();
                },
                function (sb, action) {
                    if(!action.inverse ) {
                        sb.append("move left {0} units, ".format(action.rawValue));
                    } else {
                        sb.append("move in from right {0} units, ".format(action.rawValue));
                    }
                    return null;
                }
        );


        this.registerOperation(
                '>',
                function (newAction) {
                    if (newAction.rawValue == LabaDefaultValueFinal) {
                        newAction.rawValue = newAction.elem.offsetWidth;
                    }
                    if(!newAction.inverse){
                        newAction.fromValue = newAction.elem.labaTransformX;
                        newAction.toValue = newAction.elem.labaTransformX + newAction.rawValue;
                    }else{
                        newAction.fromValue = newAction.elem.labaTransformX - newAction.rawValue;
                        newAction.toValue = newAction.elem.labaTransformX;
                    }
                    return newAction;
                },
                function (elem, v, action) {
					elem.labaTransformX = v
					elem.labaCommitElemVars();
                },
                function (sb, action) {
                    if(!action.inverse) {
                        sb.append("move right {0} units, ".format(action.rawValue));
                    } else {
                        sb.append("move in from left {0} units, ".format(action.rawValue));
                    }
                    return null;
                }
        );

        this.registerOperation(
                '^',
                function (newAction) {
                    if (newAction.rawValue == LabaDefaultValueFinal) {
                        newAction.rawValue = newAction.elem.offsetHeight;
                    }
                    if(!newAction.inverse){
                        newAction.fromValue = newAction.elem.labaTransformY;
                        newAction.toValue = newAction.elem.labaTransformY - newAction.rawValue;
                    }else{
                        newAction.fromValue = newAction.elem.labaTransformY + newAction.rawValue;
                        newAction.toValue = newAction.elem.labaTransformY;
                    }
                    return newAction;
                },
                function (elem, v, action) {
                    elem.labaTransformY = v
					elem.labaCommitElemVars();
                },
                function (sb, action) {
                    if(!action.inverse ) {
                        sb.append("move up {0} units, ".format(action.rawValue));
                    } else {
                        sb.append("move in from below {0} units, ".format(action.rawValue));
                    }
                    return null;
                }
        );

        this.registerOperation(
                'v',
                function (newAction) {
                    if (newAction.rawValue == LabaDefaultValueFinal) {
                        newAction.rawValue = newAction.elem.offsetHeight;
                    }
                    if(!newAction.inverse){
                        newAction.fromValue = newAction.elem.labaTransformY;
                        newAction.toValue = newAction.elem.labaTransformY + newAction.rawValue;
                    }else{
                        newAction.fromValue = newAction.elem.labaTransformY - newAction.rawValue;
                        newAction.toValue = newAction.elem.labaTransformY;
                    }

                    return newAction;
                },
                function (elem, v, action) {
                    elem.labaTransformY = v
					elem.labaCommitElemVars();
                },
                function (sb, action) {
                    if(!action.inverse ) {
                        sb.append("move down {0} units, ".format(action.rawValue));
                    } else {
                        sb.append("move in from above {0} units, ".format(action.rawValue));
                    }
                    return null;
                }
        );

        this.registerOperation(
                's',
                function (newAction) {
                    if (newAction.rawValue == LabaDefaultValueFinal) {
                        newAction.rawValue = 1.0;
                    }
                    if(!newAction.inverse){
                        newAction.fromValue = newAction.elem.labaScale;
                        newAction.toValue = newAction.rawValue;
                    }else{
                        newAction.fromValue = (newAction.rawValue > 0.5 ? 0.0 : 1.0);
                        newAction.toValue = newAction.rawValue;
                    }
                    return newAction;
                },
                function (elem, v, action) {
                    elem.labaScale = v
                    elem.labaCommitElemVars();
                },
                function (sb, action) {
                    if(!action.inverse ) {
                        sb.append("scale to {0}%, ".format(action.rawValue * 100.0));
                    } else {
                        sb.append("scale in from {0}%, ".format(action.rawValue * 100.0));
                    }
                    return null;
                }
        );


        this.registerOperation(
                'r',
                function (newAction) {
                    if (newAction.rawValue == LabaDefaultValueFinal) {
                        newAction.rawValue = 0.0;
                    }
                    if(!newAction.inverse){
                        newAction.fromValue = newAction.elem.labaRotationZ;
                        newAction.toValue = newAction.elem.labaRotationZ - newAction.rawValue;
                    }else{
                        newAction.fromValue = newAction.elem.labaRotationZ + newAction.rawValue;
                        newAction.toValue = newAction.elem.labaRotationZ;
                    }
                    return newAction;
                },
                function (elem, v, action) {
                    elem.labaRotationZ = v;
					elem.labaCommitElemVars();
                },
                function (sb, action) {
                    if(!action.inverse ) {
                        sb.append("rotate around z by {0}, ".format(action.rawValue));
                    } else {
                        sb.append("rotate in from around z by {0}, ".format(action.rawValue));
                    }
                    return null;
                }
        );

        this.registerOperation(
                'p',
                function (newAction) {
                    if (newAction.rawValue == LabaDefaultValueFinal) {
                        newAction.rawValue = 0.0;
                    }
                    if(!newAction.inverse){
                        newAction.fromValue = newAction.elem.labaRotationX;
                        newAction.toValue = newAction.elem.labaRotationX - newAction.rawValue;
                    }else{
                        newAction.fromValue = newAction.elem.labaRotationX + newAction.rawValue;
                        newAction.toValue = newAction.elem.labaRotationX;
                    }

                    return newAction;
                },
                function (elem, v, action) {
                    elem.labaRotationX = v;
					elem.labaCommitElemVars();
                },
                function (sb, action) {
                    if(!action.inverse ) {
                        sb.append("rotate around x by {0}, ".format(action.rawValue));
                    } else {
                        sb.append("rotate in from around x by {0}, ".format(action.rawValue));
                    }
                    return null;
                }
        );

        this.registerOperation(
                'w',
                function (newAction) {
                    if (newAction.rawValue == LabaDefaultValueFinal) {
                        newAction.rawValue = 0.0;
                    }
                    if(!newAction.inverse){
                        newAction.fromValue = newAction.elem.labaRotationY;
                        newAction.toValue = newAction.elem.labaRotationY - newAction.rawValue;
                    }else{
                        newAction.fromValue = newAction.elem.labaRotationY + newAction.rawValue;
                        newAction.toValue = newAction.elem.labaRotationY;
                    }
                    return newAction;
                },
                function (elem, v, action) {
                    elem.labaRotationY = v;
					elem.labaCommitElemVars();
                },
                function (sb, action) {
                    if(!action.inverse ) {
                        sb.append("rotate around y by {0}, ".format(action.rawValue));
                    } else {
                        sb.append("rotate in from around y by {0}, ".format(action.rawValue));
                    }
                    return null;
                }
        );

		
        this.registerOperation(
                'f',
                function (newAction) {
                    if (newAction.rawValue == LabaDefaultValueFinal) {
                        newAction.rawValue = 1.0;
                    }
                    if(!newAction.inverse){
                        newAction.fromValue = newAction.elem.labaAlpha;
                        newAction.toValue = newAction.rawValue;
                    }else{
                        newAction.fromValue = (newAction.rawValue > 0.5 ? 0.0 : 1.0);
                        newAction.toValue = newAction.rawValue;
                    }
                    return newAction;
                },
                function (elem, v, action) {
                    elem.labaAlpha = v;
					elem.labaCommitElemVars();
                },
                function (sb, action) {
                    if(!action.inverse ) {
                        sb.append("fade to {0}%, ".format(action.rawValue * 100.0));
                    } else {
                        sb.append("fade from {0}% to {1}%, ".format(action.fromValue * 100.0,action.toValue * 100.0));
                    }
                    return null;
                }
        );
	}
}

var Laba = new _Laba();



class Matrix {    
    constructor(m00,m01,m02,m03,m10,m11,m12,m13,m20,m21,m22,m23,m30,m31,m32,m33) {
        this.m00 = m00; this.m01 = m01; this.m02 = m02; this.m03 = m03;
        this.m10 = m10; this.m11 = m11; this.m12 = m12; this.m13 = m13;
        this.m20 = m20; this.m21 = m21; this.m22 = m22; this.m23 = m23;
        this.m30 = m30; this.m31 = m31; this.m32 = m32; this.m33 = m33;
    }
    
	static identity() {
	    return new Matrix(
	        1.0,  0.0,  0.0,  0.0,
	        0.0,  1.0,  0.0,  0.0,
	        0.0,  0.0,  1.0,  0.0,
	        0.0,  0.0,  0.0,  1.0
	    )
	}
	
	static translate(x, y, z) {
	    return new Matrix(
	        1.0,  0.0,  0.0,  x,
	        0.0,  1.0,  0.0,  y,
	        0.0,  0.0,  1.0,  z,
	        0.0,  0.0,  0.0,  1.0
	    )
	}

	static scale(x, y, z) {
	    return new Matrix(
	        x,  0.0,  0.0,  0.0,
	        0.0,  y,  0.0,  0.0,
	        0.0,  0.0,  z,  0.0,
	        0.0,  0.0,  0.0,  1.0
	    )
	}

	static rotateX(angle_in_rad) {
	    let s = Math.sin(angle_in_rad), c = Math.cos(angle_in_rad)
	    return new Matrix(
	        1.0,  0.0,  0.0,  0.0,
	        0.0,  c, -s,  0.0,
	        0.0,  s,  c,  0.0,
	        0.0,  0.0,  0.0,  1.0
	    )
	}

	static rotateY(angle_in_rad) {
	    let s = Math.sin(angle_in_rad), c = Math.cos(angle_in_rad)
	    return new Matrix(
	        c,  0.0,  s,  0.0,
	        0.0,  1.0,  0.0,  0.0,
	        -s,  0.0,  c,  0.0,
	        0.0,  0.0,  0.0,  1.0
	    )
	}

	static rotateZ(angle_in_rad) {
	let s = Math.sin(angle_in_rad), c = Math.cos(angle_in_rad)
	    return new Matrix(
	        c, -s,  0.0,  0.0,
	        s,  c,  0.0,  0.0,
	        0.0,  0.0,  1.0,  0.0,
	        0.0,  0.0,  0.0,  1.0
	    )
	}
	
	

	static ortho(left, right, bottom, top, near, far) {
	    let l = left, r = right, b = bottom, t = top, n = near, f = far
	    let tx = -(r + l) / (r - l)
	    let ty = -(t + b) / (t - b)
	    let tz = -(f + n) / (f - n)
	    return new Matrix(
	        2.0 / (r - l),  0.0,            0.0,            tx,
	        0.0,            2.0 / (t - b),  0.0,            ty,
	        0.0,            0.0,            -2.0 / (f - n),  tz,
	        0.0,            0.0,            0.0,            1.0
	    )
	}

	static ortho2d(left, right, bottom, top) {
	    return new Matrix.ortho(left, right, bottom, top, -1, 1)
	}

	static frustrum(left, right, bottom, top, nearval, farval) {
    
	    let x = (2.0 * nearval) / (right - left)
	    let y = (2.0 * nearval) / (top - bottom)
	    let a = (right + left) / (right - left)
	    let b = (top + bottom) / (top - bottom)
	    let c = -(farval + nearval) / ( farval - nearval)
	    let d = -(2.0 * farval * nearval) / (farval - nearval)
    
	    return new Matrix(
	        x,              0.0,            a,            0,
	        0.0,            y,              b,            0,
	        0.0,            0.0,            c,            d,
	        0.0,            0.0,            -1.0,         0.0
	    )
	}

	static perspective(fovy, aspect, zNear, zFar) {
	    let ymax = zNear * tan(fovy * Float.pi / 360.0)
	    let ymin = -ymax
	    let xmin = ymin * aspect
	    let xmax = ymax * aspect
	    return m4_frustrum(xmin, xmax, ymin, ymax, zNear, zFar)
	}

	static multiply(a, b) {
	    var result = Matrix.identity()

	    result.m00  = a.m00 * b.m00  + a.m01 * b.m10  + a.m02 * b.m20   + a.m03 * b.m30
	    result.m10  = a.m10 * b.m00  + a.m11 * b.m10  + a.m12 * b.m20   + a.m13 * b.m30
	    result.m20  = a.m20 * b.m00  + a.m21 * b.m10  + a.m22 * b.m20  + a.m23 * b.m30
	    result.m30  = a.m30 * b.m00  + a.m31 * b.m10  + a.m32 * b.m20  + a.m33 * b.m30
    
	    result.m01  = a.m00 * b.m01  + a.m01 * b.m11  + a.m02 * b.m21   + a.m03 * b.m31
	    result.m11  = a.m10 * b.m01  + a.m11 * b.m11  + a.m12 * b.m21   + a.m13 * b.m31
	    result.m21  = a.m20 * b.m01  + a.m21 * b.m11  + a.m22 * b.m21  + a.m23 * b.m31
	    result.m31  = a.m30 * b.m01  + a.m31 * b.m11  + a.m32 * b.m21  + a.m33 * b.m31
    
	    result.m02  = a.m00 * b.m02  + a.m01 * b.m12  + a.m02 * b.m22  + a.m03 * b.m32
	    result.m12  = a.m10 * b.m02  + a.m11 * b.m12  + a.m12 * b.m22  + a.m13 * b.m32
	    result.m22 = a.m20 * b.m02  + a.m21 * b.m12  + a.m22 * b.m22 + a.m23 * b.m32
	    result.m32 = a.m30 * b.m02  + a.m31 * b.m12  + a.m32 * b.m22 + a.m33 * b.m32
    
	    result.m03 = a.m00 * b.m03 + a.m01 * b.m13 + a.m02 * b.m23  + a.m03 * b.m33
	    result.m13 = a.m10 * b.m03 + a.m11 * b.m13 + a.m12 * b.m23  + a.m13 * b.m33
	    result.m23 = a.m20 * b.m03 + a.m21 * b.m13 + a.m22 * b.m23 + a.m23 * b.m33
	    result.m33 = a.m30 * b.m03 + a.m31 * b.m13 + a.m32 * b.m23 + a.m33 * b.m33
    
	    return result;
	}
	
}


"""###
#endif
}
}


public extension Pamphlet {
    static func LabaJsGzip() -> Data {
        return gzip_data!
    }
}

private let gzip_data = Data(base64Encoded:"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")