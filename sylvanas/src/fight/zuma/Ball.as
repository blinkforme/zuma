package fight.zuma
{
    import enums.BallDepth;

    import fight.*;
    import fight.power.PowerBase;
    import fight.state.ball.FireMoveState;
    import fight.state.ball.InsertState;
    import fight.state.ball.PullingState;
    import fight.state.ball.RepelingState;
    import fight.state.ball.SqueezeState;

    import laya.d3.math.Vector2;
    import laya.display.Animation;
    import laya.display.Sprite;
    import laya.maths.Point;
    import laya.ui.Image;
    import laya.utils.Handler;

    import manager.AnimalManger;
    import manager.GameConst;
    import manager.GameTools;
    import manager.SpineTemplet;

    import struct.DNode;
    import struct.fsm.FSM;

    public class Ball extends FightBase
    {
        private var _ani:Sprite;
        private var _explodeAni:SpineTemplet

        private var _color:Number = -1;

        private var _width:Number = 0;
        private var _height:Number = 0;
        private var _anchorX:Number = 0.5;
        private var _anchorY:Number = 0.5;
        private var _initVct:Vector2 = (1, 0);

        //半径
        public static var RADIUS:Number = DIAMETER / 2
        //直径
        public static var DIAMETER:Number = GameConst.BallWith
        //链表节点
        private var _node:DNode = null;

        //所在链
        private var _chain:FightChain = null;

        //前端是否有连接球
        private var _isForwardTouch:Boolean = false

        //后端是否有连接球
        private var _isBackTouch:Boolean = false


        //下一步要走的距离
        private var _nextMoveDistance:Number = 1

        //下一步移动到的点
        private var _nextPoint:Point;

        //是否在线上
        private var _isOnLine:Boolean = false

        //正在爆炸中
        private var _isExploding:Boolean = false


        //曲线中地图位置
        private var _curPos:LinePosition;
        private var _targetPosition:LinePosition

        private var _screenPos:Point = new Point();

        //此球上的力
        private var _power:PowerBase = null;


        //连消次数
        private var _pullPowerLevel:Number = 1

        private var _root:Sprite;

        public static var _ballArr:Array = [];


        private var _fsm:FSM


        public static function create(parent:Sprite, type:Number = null):Ball
        {
            var ret:Ball = CachePool.GetCache("Ball", type + "", Ball);
            _ballArr.push(ret);
            ret.init(parent, type);
            return ret;
        }

        public function get allSceneScrennPos():Point
        {
            return CoordGm.instance.zumaTopoDesToAllScr(new Point(_ani.x, _ani.y));
        }

        public function aniPoint():Point
        {
            return CoordGm.instance.zumaTopoScrToDes(new Point(_ani.x, _ani.y));
        }


        public function playScoreAni():void
        {

            if (FightManager.instance.exitBtton != true)
            {
                FightManager.instance.showBallPowerChange(new Point(_ani.x, _ani.y), 1);
            }
        }

        public function startExplode():void
        {
            if (!isExploding)
            {
                isExploding = true
                chain.cleanBall(this)
                playExplodeAni()
                playScoreAni()
                _ani.visible = false
            }
        }

        public function playExplodeAni():void
        {
            if (!_explodeAni)
            {
                _explodeAni = new SpineTemplet("boom1")
            }
            _explodeAni.setPos(_ani.x, _ani.y)
            _explodeAni.visible = true

            _root.addChild(_explodeAni)
            _explodeAni.play("H5_bosszhadan2", false, Handler.create(this, onEndExplode))
        }

        public function onEndExplode():void
        {
            isExploding = false
        }

        public function set visible(visible:Boolean):void
        {
            _ani.visible = visible
            if (_explodeAni)
            {
                _explodeAni.visible = visible
            }
        }

        private function init(root:Sprite, type:Number):void
        {
            _fsm = new FSM(this, FireMoveState.instance, null, null)
            _root = root
            _color = type;
            _width = Ball.DIAMETER;
            _height = Ball.DIAMETER;
            if (!_ani)
            {
                if (ENV.IsFrameAnimation == false)
                {
                    _ani = new Image(CoordGm.instance.getBallSkinUrl(_color));
                    _ani.width = Ball.DIAMETER;
                    _ani.height = Ball.DIAMETER;
                } else
                {
                    _ani = AnimalManger.instance.load(CoordGm.instance.getBallFrameAniName(_color));
                    _ani.scale(_width / 76, _width / 76);
                }
                root.addChild(_ani);
            }
            _ani.pivot(_width * _anchorX, _height * _anchorY);
            _ani.visible = true;
            playAnimation();
            _isValid = true;
        }

        public function playAnimation():void
        {
            if (ENV.IsFrameAnimation == true)
            {
                (_ani as Animation).play(0, true);
            }
        }


        public function get power():PowerBase
        {
            return _power;
        }

        public function set power(value:PowerBase):void
        {
            _power = value;
        }

        public function get isOnLine():Boolean
        {
            return _isOnLine;
        }

        public function set isOnLine(value:Boolean):void
        {
            _isOnLine = value;
        }

        public function get isForwardTouch():Boolean
        {
            return _isForwardTouch;
        }

        public function getInsertSpeed():Number
        {
            return 400 + chain.static_power.nowSpeed()
        }

        public function getSqueezeSpeed():Number
        {
            return 400 + chain.static_power.nowSpeed()
        }

        public function set isForwardTouch(value:Boolean):void
        {
            _isForwardTouch = value
        }

        public function get isBackTouch():Boolean
        {
            return _isBackTouch;
        }


        public function set isBackTouch(value:Boolean):void
        {
            _isBackTouch = value
        }

        public function Ball():void
        {

        }

        public function get node():DNode
        {
            return _node;
        }

        public function set node(value:DNode):void
        {
            _node = value;
        }


        override public function update(delta:Number):void
        {
            if (!isValid())
            {
                return
            }
            updateRotation(delta);
        }


        public function setPos(position:LinePosition):void
        {
            _screenPos = CoordGm.instance.zumaTopoDesToScr(position.point);
            _ani.pos(_screenPos.x, _screenPos.y);
            _curPos = position
        }


        public function get nextMoveDistance():Number
        {
            return _nextMoveDistance;
        }

        public function set nextMoveDistance(value:Number):void
        {
            _nextMoveDistance = value;
        }


        public function updateRotation(delta:Number):void
        {

            _ani.rotation += delta * 100;
        }

        override public function isValid():Boolean
        {
            _isValid = true;
            if (!_ani || _ani.visible == false)
            {
                _isValid = false
            }
            return _isValid;
        }

        override public function destroy():void
        {
            if (power)
            {
                power.isValid = false
            }


            _ani.visible = false;


            //            CachePool.Cache("Ball", _color + "", this);
        }


        public function get color():Number
        {
            return _color;
        }


        public function get width():Number
        {
            return _width;
        }

        public function set width(value:Number):void
        {
            _width = value;
        }

        public function get curPos():LinePosition
        {
            return _curPos;
        }

        public function getNextTouchedBall():Ball
        {
            return chain.getNextTouchedBall(this)
        }

        public function getPrevTouchedBall():Ball
        {
            return chain.getPrevTouchedBall(this)
        }

        public function getNextBall():Ball
        {
            return chain.getNextBall(this)
        }

        public function getPrevBall():Ball
        {
            return chain.getPrevBall(this)
        }

        public function isFirstBall():Boolean
        {
            return chain.isFirstBall(this)
        }

        public function isLastBall():Boolean
        {
            return chain.isLastBall(this)
        }


        public function get nextPoint():Point
        {
            return _nextPoint;
        }

        public function set nextPoint(value:Point):void
        {
            _nextPoint = value;
        }

        public function set curPos(value:LinePosition):void
        {
            _curPos = value;
        }


        public function get chain():FightChain
        {
            return _chain;
        }

        public function set chain(value:FightChain):void
        {
            _chain = value;
        }

        public function get isExploding():Boolean
        {
            return _isExploding;
        }

        public function set isExploding(value:Boolean):void
        {
            _isExploding = value;
        }

        public function get isInserting():Boolean
        {
            return fsm.isInState(InsertState)
        }

        public function get isSqueezing():Boolean
        {
            return fsm.isInState(SqueezeState)
        }

        public function get isRepeling():Boolean
        {
            return fsm.isInState(RepelingState)
        }

        public function get isPulling():Boolean
        {
            return fsm.isInState(PullingState)
        }


        public function get isInsertFront():Boolean
        {

            var nextTouchedOnlineBall:Ball = getNextTouchedOnlineBall()
            if (nextTouchedOnlineBall)
            {
                return true
            } else
            {
                return false
            }

            if (_isBackTouch)
            {
                var nextBall:Ball = getNextBall()
                if (nextBall.isInserting)
                {
                    return nextBall.isInsertFront
                } else
                {
                    return true
                }
            }

            if (_isForwardTouch)
            {
                var prevBall:Ball = getPrevBall()

                if (prevBall.isInserting)
                {
                    return prevBall.isInsertFront
                } else
                {
                    return false
                }
            }
        }

        public function set rotateSpeed(moveSpeed:Number):void
        {
            if (ENV.IsFrameAnimation == true)
            {

                (_ani as Animation).interval = 1000 / (moveSpeed / Ball.DIAMETER * 50);
            }
        }

        public function getDepth(distance:Number):Number
        {
            var blocks:Array = ZumaMap._roadblockArr
            for (var i = 0; i < blocks.length; i++)
            {
                var block:RoadBlock = blocks[i];
                var dep:Number = block.getDepthByDistance(distance)
                if (dep == BallDepth.UP || dep == BallDepth.DOWN)
                {
                    return dep
                }
            }
            return BallDepth.MIDDLE
        }


        public function get zOrder():Number
        {
            if (_ani)
            {
                return _ani.zOrder
            }
            return BallDepth.MIDDLE
        }

        public function set zOrder(index:Number):void
        {
            if (_ani)
            {
                _ani.zOrder = index
            }
            if (_explodeAni)
            {
                _explodeAni.zOrder = index
            }
        }

        public function calcBallZOrder():void
        {
            var dep:Number = getDepth(_curPos.curDistance)
            zOrder = dep
        }
        private function setBallPos(point:Point):void
        {
            _screenPos = CoordGm.instance.zumaTopoDesToScr(point);
            _ani.pos(_screenPos.x, _screenPos.y);


            if (!isInserting && !fsm.isInState(FireMoveState))
            {
                calcBallZOrder()
                if (ENV.IsFrameAnimation)
                {
                    if (!_curPos.curLinePoint.isLastPoint())
                    {
                        _ani.rotation = GameTools.CalLineAngle(new Point(_initVct.x, _initVct.y),
                                new Point(_curPos.curLinePoint.nVector.x, _curPos.curLinePoint.nVector.y)) - 90
                    }
                }
            }

            if (_explodeAni)
            {
                _explodeAni.setPos(_screenPos.x, _screenPos.y)
            }

        }


        public function getSameColorBalls():Array
        {
            var balls:Array = []
            balls.push(this)

            var prevBall:Ball = this.getPrevTouchedBall();

            //向前搜索
            while (prevBall)
            {
                if (prevBall.color == this.color && !prevBall.isInserting)
                {
                    balls.unshift(prevBall)
                    prevBall = prevBall.getPrevTouchedBall()
                } else
                {
                    break
                }
            }
            //向后搜索
            var nextBall:Ball = this.getNextTouchedBall();
            while (nextBall)
            {
                if (nextBall.color == this.color && !nextBall.isInserting)
                {
                    balls.push(nextBall)
                    nextBall = nextBall.getNextTouchedBall()
                } else
                {
                    break
                }
            }
            return balls
        }

        public function pullDirect(distance:Number):void
        {
            var prevBall:Ball = getPrevBall()
            if (isInserting)
            {
                if (prevBall && prevBall.isBackTouch)
                {
                    prevBall.pullDirect(distance)
                }
            } else
            {
                this.move(distance)
                if (prevBall && prevBall.isBackTouch)
                {
                    prevBall.pullDirect(distance)
                }
            }

        }

        //        distance 小于0
        public function pull(distance:Number):void
        {
            var nextBall:Ball = getNextBall()
            if (isInserting)
            {
                pullDirect(distance)
            } else
            {
                if (nextBall)
                {
                    var overDistance:Number = _curPos.curDistance - nextBall.targetPosition.curDistance

                    if ((overDistance + distance) > Ball.DIAMETER)
                    {
                        pullDirect(distance)
                    } else
                    {
                        var moveDistance:Number = -(overDistance - Ball.DIAMETER)
                        isBackTouch = true
                        nextBall.isForwardTouch = true
                        pullDirect(moveDistance)
                    }
                } else
                {
                    pullDirect(distance)
                }
            }
        }


        public function pushBack(distance:Number):void
        {
            if (isInserting)
            {

            } else
            {
                var nextBall:Ball = getNextBall()
                if (nextBall)
                {
                    if (nextBall.isInserting)
                    {
                        if ((_curPos.curDistance - nextBall.targetPosition.curDistance) <= Ball.DIAMETER)
                        {
                            isBackTouch = true
                            nextBall.isForwardTouch = true
                        }
                        this.move(distance)
                    } else
                    {
                        if (nextBall.isBackTouch)
                        {
                            this.move(distance)
                            nextBall.pushBack(distance)
                        } else
                        {
                            var overDistance:Number = _curPos.curDistance - nextBall.curPos.curDistance

                            if ((overDistance + distance) <= Ball.DIAMETER)
                            {
                                isBackTouch = true;
                                nextBall.isForwardTouch = true;

                                var remain_distance:Number = (overDistance + distance) - Ball.DIAMETER
                                this.move(distance)
                                nextBall.pushBack(remain_distance)
                            } else
                            {
                                this.move(distance)
                            }
                        }

                    }
                } else
                {
                    this.move(distance)
                }
            }

        }

        public function name():void
        {

        }

        public function pushForward(distance:Number):void
        {
            if (isInserting)
            {

            } else
            {
                var prevBall:Ball = getPrevBall()
                if (prevBall)
                {
                    if (prevBall.isInserting)
                    {
                        if ((prevBall.targetPosition.curDistance - _curPos.curDistance) <= Ball.DIAMETER)
                        {
                            isForwardTouch = true
                            prevBall.isBackTouch = true
                        }
                        this.move(distance)
                        prevBall.pushForward(distance)
                    } else
                    {
                        if (prevBall.isBackTouch)
                        {
                            this.move(distance)
                            prevBall.pushForward(distance)
                        } else
                        {
                            var overDistance:Number = prevBall.curPos.curDistance - _curPos.curDistance
                            if ((overDistance - distance) <= Ball.DIAMETER)
                            {
                                isForwardTouch = true
                                prevBall.isBackTouch = true
                                var remain_distance:Number = Ball.DIAMETER - overDistance + distance
                                this.move(distance)
                                prevBall.pushForward(remain_distance)
                            } else
                            {
                                this.move(distance)
                            }
                        }

                    }
                } else
                {
                    this.move(distance)
                }
            }
        }

        public function moveTo(point:Point):void
        {
            setBallPos(point)
        }

        public function move(distance:Number):void
        {
            _curPos.move(distance)
            setBallPos(_curPos.point)
            if (_curPos.curDistance == 0)
            {
                chain.returnBackBall(this)
            }
        }

        public function getNextTouchedOnlineBallDistance():Number
        {
            var num:Number = 1
            var nextTouchedBall:Ball = getNextTouchedBall()
            while (nextTouchedBall)
            {
                if (!nextTouchedBall.isInserting)
                {
                    return num
                } else
                {
                    num++
                    nextTouchedBall = nextTouchedBall.getNextTouchedBall()
                }
            }
            console.error("getNextTouchedOnlineBallDistance", -1, this)
            return -1
        }


        public function getNextTouchedOnlineBall():Ball
        {
            var nextTouchedBall:Ball = getNextTouchedBall()
            while (nextTouchedBall)
            {
                if (!nextTouchedBall.isInserting)
                {
                    return nextTouchedBall
                } else
                {
                    nextTouchedBall = nextTouchedBall.getNextTouchedBall()
                }
            }
            return null
        }

        public function getPrevTouchedOnlineBallDistance():Number
        {
            var num:Number = 1
            var prevTouchedBall:Ball = getPrevTouchedBall()
            while (prevTouchedBall)
            {
                if (!prevTouchedBall.isInserting)
                {
                    return num
                } else
                {
                    num++
                    prevTouchedBall = prevTouchedBall.getPrevTouchedBall()
                }
            }
            console.error("getPrevTouchedOnlineBallDistance", -1, this)

            return -1
        }

        public function getPrevTouchedOnlineBall():Ball
        {
            var prevTouchedBall:Ball = getPrevTouchedBall()
            while (prevTouchedBall)
            {
                if (!prevTouchedBall.isInserting)
                {
                    return prevTouchedBall
                } else
                {
                    prevTouchedBall = prevTouchedBall.getPrevTouchedBall()
                }
            }
            return null
        }

        public function calcTargetPosition():void
        {
            if (isInserting)
            {
                var nextTouchedOnlineBall:Ball = getNextTouchedOnlineBall()
                var prevTouchedOnlineBall:Ball = getPrevTouchedOnlineBall()
                if (nextTouchedOnlineBall)
                {
                    var overNum:Number = getNextTouchedOnlineBallDistance()
                    _targetPosition = nextTouchedOnlineBall.targetPosition.copy().move(Ball.DIAMETER * overNum)
                    if (prevTouchedOnlineBall)
                    {
                        if (!prevTouchedOnlineBall.isSqueezing)
                        {
                            prevTouchedOnlineBall.fsm.changeState(SqueezeState.instance)
                        }
                    }
                } else
                {
                    if (prevTouchedOnlineBall)
                    {
                        var overNum:Number = getPrevTouchedOnlineBallDistance()
                        _targetPosition = prevTouchedOnlineBall.targetPosition.copy().move(-Ball.DIAMETER * overNum)
                    }
                }

                //
                //                if (isInsertFront)
                //                {
                //                    var num:Number = 1
                //                    var nextBall:Ball = getNextBall()
                //                    while (nextBall && nextBall.isInserting)
                //                    {
                //                        nextBall = nextBall.getNextBall()
                //                        num++
                //                    }
                //                    _targetPosition = nextBall.targetPosition.copy().move(Ball.DIAMETER * num)
                //                } else
                //                {
                //                    var num:Number = 1
                //                    var prevBall:Ball = getPrevBall()
                //                    while (prevBall && prevBall.isInserting)
                //                    {
                //                        prevBall = prevBall.getPrevBall()
                //                        num++
                //                    }
                //                    _targetPosition = prevBall.targetPosition.copy().move(-Ball.DIAMETER * num)
                //                }

            }
        }


        public function set targetPosition(value:LinePosition):void
        {
            _targetPosition = value;
        }

        public function get targetPosition():LinePosition
        {
            if (isInserting)
            {
                return _targetPosition
            } else
            {
                return _curPos
            }
        }


        public function get x():Number
        {
            return _ani.x
        }

        public function get y():Number
        {
            return _ani.y
        }

        public function get fsm():FSM
        {
            return _fsm;
        }

        public function set fsm(value:FSM):void
        {
            _fsm = value;
        }


        public function get pullPowerLevel():Number
        {
            return _pullPowerLevel;
        }

        public function set pullPowerLevel(value:Number):void
        {
            _pullPowerLevel = value;
        }
    }
}