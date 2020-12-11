package fight
{
    import conf.cfg_scene;

    import enums.BallDepth;
    import enums.SoundType;

    import fight.power.StaticPower;
    import fight.state.ball.InsertState;
    import fight.state.ball.StaticState;
    import fight.state.chain.NormalBornState;
    import fight.zuma.Ball;
    import fight.zuma.ZumaManager;
    import fight.zuma.ZumaMap;

    import laya.d3.math.Vector2;
    import laya.maths.Point;

    import manager.GameEvent;
    import manager.GameEventDispatch;
    import manager.GameSoundManager;
    import manager.GameTools;

    import struct.DNode;
    import struct.LinkedList;
    import struct.fsm.FSM;

    public class FightChain
    {
        private var _list:LinkedList;

        private var _static_power:StaticPower = null


        private var _line:Line;

        private var _bornBalls:Array = []

        private var _cfg:cfg_scene

        private var lastExplodeTime:Number = 0
        private var combo:Number = 1
        private var _freezeTime:Number = 0
        private var _backDistance:Number = 0

        private var _fsm:FSM

        public function FightChain(cfg:cfg_scene)
        {
            _cfg = cfg
            _list = new LinkedList()
            _static_power = new StaticPower(this, null, _cfg.speed, _cfg.startBallNum * Ball.DIAMETER, _cfg.startFastSpeed)
            _line = Line.create(ZumaMap._mapArray);
            _fsm = new FSM(this, NormalBornState.instance, null, null)
        }


        public function checkBornBall():void
        {
            var tailBall:Ball = this.getTailBall()
            //出生球逻辑
            if (tailBall && !tailBall.isInserting)
            {
                if (tailBall.curPos.curDistance > Ball.DIAMETER)
                {
                    var bornBall:Ball = this.bornBall()

                    if (tailBall.curPos.curDistance < Ball.DIAMETER * 2)
                    {
                        bornBall.isForwardTouch = true
                        tailBall.isBackTouch = true
                        bornBall.setPos(tailBall.curPos.copy().move(-Ball.DIAMETER))
                    }
                }
            } else
            {
                this.bornBall()
            }
        }

        public function canShoot():Boolean
        {
            return !_static_power.isFastTime()
        }


        public function getNextTouchedBall(ball:Ball):Ball
        {

            if (ball.isBackTouch)
            {
                return getNextBall(ball)
            }
        }

        public function getPrevTouchedBall(ball:Ball):Ball
        {

            if (ball.isForwardTouch)
            {
                return getPrevBall(ball)
            }
        }

        public function getNextBall(ball:Ball):Ball
        {
            var nextNode:DNode = ball.node.next
            if (list.isHeadNode(nextNode))
            {
                return null
            }
            return nextNode.data
        }

        //获取前面的球
        public function getPrevBall(ball:Ball):Ball
        {
            var prevNode:DNode = ball.node.prev
            if (list.isHeadNode(prevNode))
            {
                return null
            }
            return prevNode.data
        }


        //是否是最前面的球
        public function isFirstBall(ball:Ball):Boolean
        {
            return list.isFirstNode(ball.node)
        }

        //是否是最后面的球
        public function isLastBall(ball:Ball):Boolean
        {
            return list.isLastNode(ball.node)
        }


        public function isEmpty():Boolean
        {
            return _list.isEmpty()
        }


        public function getHeadBall():Ball
        {
            if (isEmpty())
            {
                return null
            } else
            {
                return _list.head.next.data
            }
        }

        public function getTailBall():Ball
        {
            if (isEmpty())
            {
                return null
            } else
            {
                return _list.head.prev.data
            }
        }


        //球回退到原点，则返回到cache中
        public function returnBackBall(ball:Ball):void
        {
            ball.visible = false
            cleanBall(ball);
            _bornBalls.unshift(ball)
        }


        public function bornBall():Ball
        {

            if (_bornBalls.length == 0)
            {
                for (var i:Number = 0; i < 3; i++)
                {
                    var ball:Ball = ZumaManager.instance.createActiveBall();
                    ball.visible = false
                    _bornBalls.push(ball)
                }
            }
            var ball:Ball = _bornBalls.splice(0, 1)[0] as Ball
            ball.visible = true

            var node:DNode = _list.append(ball)
            ball.node = node
            ball.chain = this


            var startPosition:LinePosition = new LinePosition(line.headPoint, 0, _line)
            ball.setPos(startPosition)

            ball.isForwardTouch = false
            ball.isBackTouch = false
            ball.isOnLine = true
            ball.fsm.currentState = StaticState.instance
            return ball

        }

        public function cleanBall(ball:Ball):void
        {


            var prevBall:Ball = ball.getPrevBall()
            var nextBall:Ball = ball.getNextBall()
            if (prevBall)
            {
                prevBall.isBackTouch = false
            }
            if (nextBall)
            {
                nextBall.isForwardTouch = false
            }
            ball.isForwardTouch = false
            ball.isBackTouch = false
            ball.isOnLine = false
            _list.remove(ball.node)
        }


        //发射球消除
        public function doHitEliminate(balls:Array):void
        {
            GameSoundManager.playExcelMusic(SoundType.CHIME_MUISIC(1))
            doAttack(balls)
        }


        //碰撞检测
        public function collision(point:Point):Ball
        {

            var startBall:Ball = getTailBall()
            while (startBall)
            {
                var distance:Number = GameTools.CalPointLen(point, startBall.aniPoint())
                if (distance <= Ball.DIAMETER)
                {
                    //遮盖物以下的球
                    if (startBall.zOrder != BallDepth.DOWN)
                    {
                        return startBall
                    }
                }
                startBall = startBall.getPrevBall()

            }
        }

        public function destory():void
        {
            var ball:Ball = getTailBall()
            while (ball)
            {
                ball.destroy()
                ball = ball.getPrevBall()
            }

            _list.removeAll()
            _bornBalls = []
        }

        public function doAttack(balls:Array):void
        {
            var now:Number = GameTools.now()
            if (now - lastExplodeTime > 2000)
            {
                combo = 1
            } else
            {
                combo++
            }
            lastExplodeTime = now

            var totalBalls:Number = balls.length
            //不需要添加功能能量了
            //            var explodePoint:Point = balls[0].curPos.point

            //            var score:Number = FightM.instance.getPowerValueOfBall(totalBalls, combo)
            //            FightManager.instance.showBallPowerChange(explodePoint, score)
            GameEventDispatch.instance.event(GameEvent.EliminateComplete, [totalBalls, combo]);

        }

        public function checkBallIntoHole():void
        {

            var headBall:Ball = getHeadBall()
            if (headBall)
            {
                while (headBall.isInserting)
                {
                    headBall = headBall.getNextBall()
                }

                if (headBall.curPos.curLinePoint.isLastPoint())
                {
                    GameEventDispatch.instance.event(GameEvent.BallIntoHole);
                }
            }


        }

        public function update(delta:Number):void
        {
            checkBallIntoHole()


            var tailBall:Ball = getTailBall()
            while (tailBall)
            {
                if (tailBall.isInserting)
                {
                    tailBall.calcTargetPosition()
                }
                tailBall = tailBall.getPrevBall()
            }

            var tailBall:Ball = getTailBall()
            while (tailBall)
            {
                tailBall.fsm.update()
                tailBall = tailBall.getPrevBall()
            }
        }

        public function hit(ball:Ball, targetBall:Ball):void
        {

            console.log("hit")
            if (targetBall)
            {
                console.log("hit1")

                GameSoundManager.playExcelMusic(SoundType.STRIKE)

                var collisionVector:Vector2 = new Vector2(ball.x - targetBall.x, ball.y - targetBall.y)
                var ncVector:Vector2 = new Vector2()
                Vector2.normalize(collisionVector, ncVector)


                var cosAngle:Number = Vector2.dot(ncVector, targetBall.targetPosition.curLinePoint.nVector)
                console.log("hit2")


                //在珠子前方插入
                if (cosAngle > 0)
                {
                    console.log("insert front")
                    var node:DNode;
                    node = _list.front(ball, targetBall.node)
                    ball.chain = this
                    ball.node = node

                    ball.isBackTouch = true
                    ball.isForwardTouch = false
                    targetBall.isForwardTouch = true
                    ball.targetPosition = targetBall.targetPosition.copy().move(Ball.DIAMETER)
                    ball.fsm.changeState(InsertState.instance)
                    console.log("insert front end")

                }
                //在珠子后方插入
                else
                {
                    console.log("insert after")
                    var node:DNode;
                    node = _list.after(ball, targetBall.node);
                    ball.chain = this
                    ball.node = node

                    ball.isForwardTouch = true
                    ball.isBackTouch = false
                    targetBall.isBackTouch = true
                    ball.targetPosition = targetBall.targetPosition.copy().move(-Ball.DIAMETER)
                    ball.fsm.changeState(InsertState.instance)
                    console.log("insert after end")

                }
            }
        }


        public function get backDistance():Number
        {
            return _backDistance;
        }

        public function set backDistance(value:Number):void
        {
            _backDistance = value;
        }

        public function get freezeTime():Number
        {
            return _freezeTime;
        }

        public function set freezeTime(value:Number):void
        {
            _freezeTime = value;
        }

        public function get fsm():FSM
        {
            return _fsm;
        }

        public function set fsm(value:FSM):void
        {
            _fsm = value;
        }


        public function get static_power():StaticPower
        {
            return _static_power;
        }

        public function set static_power(value:StaticPower):void
        {
            _static_power = value;
        }

        public function get line():Line
        {
            return _line;
        }

        public function set line(value:Line):void
        {
            _line = value;
        }

        public function get list():LinkedList
        {
            return _list;
        }

        public function set list(value:LinkedList):void
        {
            _list = value;
        }

    }
}
