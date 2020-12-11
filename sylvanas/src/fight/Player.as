package fight
{
    import conf.cfg_role;

    import laya.display.Sprite;
    import laya.maths.Point;
    import laya.ui.Image;
    import laya.utils.Handler;

    import manager.GameConst;
    import manager.GameEvent;
    import manager.GameEventDispatch;
    import manager.SpineTemplet;

    import model.AccountM;
    import model.FightM;

    public class Player extends FightBase
    {
        private var _aniType:Number = -1;
        private var _aniName:String;

        private var _colliwidth:Number = 0;
        private var _colliheight:Number = 0;

        private var _curPos:Point = new Point(100, GameConst.war_height - 130);
        private var _screenPos:Point = new Point();

        private var _aniActionMusic:Array = [];//出现音效 受击音效 捕获音效

        private var _aniActionInfo:Array = [];//待机 行走 死亡 战斗

        private var isPlaying:Boolean = false;

        private var atkObjId:Number = -1;

        public function Player():void
        {

        }


        public static function create(parent:Sprite):Player
        {
            var ret:Player = CachePool.GetCache("Player", null, Player);
            ret.init(parent);
            return ret;
        }


        private function init(root:Sprite):void
        {
            var config:cfg_role = cfg_role.instance("" + 1);
            _aniName = config.aniName;
            _aniActionMusic = [config.comeSound, config.hitSound, config.CatchSound];
            _aniActionInfo = [config.sleepAni, config.moveAni, config.deadAni, config.atkAni, config.big_atkAni];
            _colliwidth = 90
            _colliheight = 88
            _isValid = true;
            updateZoder();
        }

        public function initPlayerData():Point
        {
            atkObjId = -1;
            _isValid = true;
            isPlaying = false;
        }

        private function actionComplete(num:Number):void
        {
            if (curAtkMonsterIsAlive(Monster._monsterArr.length - 1) == false)
            {
                return;
            }
            var one:Monster = Monster._monsterArr[atkObjId] as Monster;
            var point:Point = one.getHurtAniPoint();
            if (!point)
            {
                getAtkMonsterId();
                one = Monster._monsterArr[atkObjId] as Monster;
                point = one.getHurtAniPoint();
            }
            if (num == GameConst.action_big_atk)
            {
                FightManager.instance.showBoomChange(point, "H5_qipao")
            } else
            {
                FightManager.instance.showBoomChange(point, "H5_qipao")
            }
            one.getHurt(FightM.instance.hurtNum);
            FightManager.instance.showMonsterBooldChange(one, FightM.instance.hurtNum);
        }

        override public function update(delta:Number):void
        {
            if (!isValid())
            {
                return
            }
            if (FightM.instance.eliminateArr.length > 0)
            {
                getAtkMonsterId();
                playingATKAction();
            }
            updateZoder();
            playerVectory();
        }

        private function getAtkMonsterId():void
        {
            if (atkObjId < 0)
            {
                atkObjId = 0;
            }
            if (curAtkMonsterIsAlive(atkObjId) == true)
            {

            } else
            {
                atkObjId++;
                if (atkObjId > (Monster._monsterArr.length - 1))
                {
                    atkObjId = Monster._monsterArr.length - 1;
                }
            }
        }

        private function curAtkMonsterIsAlive(atkId:Number):Boolean
        {
            var one:Monster = Monster._monsterArr[atkId] as Monster;
            if (one.isValid() == true && one.isActionDead == false)
            {
                return true;
            }
            return false;
        }

        private function playerVectory():void
        {
            if (atkObjId == Monster._monsterArr.length - 1 && curAtkMonsterIsAlive(atkObjId) == false)
            {
                AccountM.instance.acoountType = GameConst.Account_Type_Vectory;
                //玩家胜利
                GameEventDispatch.instance.event(GameEvent.FightStop);
            }
        }

        public function playerFail():void
        {
            AccountM.instance.acoountType = GameConst.Account_Type_Fail;
            //玩家失败
            GameEventDispatch.instance.event(GameEvent.FightStop);
        }

        private function updateZoder():void
        {
            _screenPos = CoordGm.instance.warTopoDesToScr(_curPos);
        }

        public function playingATKAction():void
        {
            if (atkObjId >= 0 && curAtkMonsterIsAlive(atkObjId) == true)
            {
                if (FightM.instance.isCanShowBigSkill())
                {
                    FightM.instance.carryOutBigSkill();
                    actionComplete(GameConst.action_big_atk);
                } else
                {
                    FightM.instance.carryOutNomallSkill();
                    actionComplete(GameConst.action_atk);
                }
            }
        }

        override public function isValid():Boolean
        {
            return _isValid;
        }

        override public function destroy():void
        {
            if (!isValid())
            {
                return
            }
            _isValid=false;
            CachePool.Cache("Player", null, this);
        }

        public function curPos():Point
        {
            return _curPos;
        }
    }
}