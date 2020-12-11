package view.setting
{


    import laya.events.Event;
    import laya.media.SoundManager;
    import laya.media.SoundManager;
    import laya.utils.Handler;
    import laya.ui.Button;

    import manager.GameConst;
    import manager.GameEvent;
    import manager.GameEventDispatch;
    import manager.ResVo;
    import manager.UiManager;

    import ui.sylvanas.SettingPageUI;


    public class SettingPage extends SettingPageUI implements ResVo
    {

        private var isOpenMusic:Boolean = new Boolean();
        private var isOpenBgm:Boolean = new Boolean();

        public function SettingPage()
        {

        }

        public function StartGames(parm:Object = null):void
        {

            isOpenMusic = SoundManager.soundVolume != 0
            isOpenBgm = SoundManager.musicVolume != 0

            this.hitTestPrior = false;
            bmask.on(Event.CLICK, this, null)

            quitBtn.on(Event.CLICK, this, onQuitBtnClick);

            MusicBtn.on(Event.CLICK,this,onMusicBtnClick);
            BgmBtn.on(Event.CLICK,this,onBgmBtnClick);


            screenResize();
        }

        private function screenResize():void
        {
            bmask.width = GameConst.design_width * 1.5;
            bmask.height = GameConst.design_height * 1.5;
            this.size(Laya.stage.width, Laya.stage.height);
        }

        private function onMusicBtnClick():void{
            isOpenMusic = !isOpenMusic;
            if (isOpenMusic)
            {
                SoundManager.setSoundVolume(GameConst.default_sound);
            }
            else
            {
                SoundManager.setSoundVolume(0);
            }
            changeButtonSkin(isOpenMusic,MusicBtn);
        }

        private function onBgmBtnClick():void{
            isOpenBgm = !isOpenBgm;
            if (isOpenBgm)
            {
                SoundManager.setMusicVolume(GameConst.default_bgm_music);
            }
            else
            {
                SoundManager.setMusicVolume(0);
            }
            changeButtonSkin(isOpenBgm,BgmBtn);

        }

        private function changeButtonSkin(isOpen:Boolean,changeBtn:Button):void
        {
            if (isOpen)
            {
                changeBtn.skin = "ui/setting/btn_O_switch_on.png";
            }
            else
            {
                changeBtn.skin = "ui/setting/btn_O_switch_off.png";
            }
        }

        private function onQuitBtnClick()
        {
            UiManager.instance.closePanel("Setting", true);
        }

        private function anchorPoint()
        {
            var soundVolume:Number = SoundManager.soundVolume;
            var musicVolume:Number = SoundManager.musicVolume;
            if (soundVolume > GameConst.default_sound)
            {
                //__JS__('_czc.push(["_trackEvent","音效","提高","",soundVolume,""]);')
            } else if (soundVolume < GameConst.default_sound)
            {
                //__JS__('_czc.push(["_trackEvent","音效","降低","",soundVolume,""]);')
            }

            if (musicVolume > GameConst.default_bgm_music)
            {
                //__JS__('_czc.push(["_trackEvent","背景音乐","提高","",musicVolume,""]);')
            } else if (musicVolume < GameConst.default_bgm_music)
            {
                //__JS__('_czc.push(["_trackEvent","背景音乐","降低","",musicVolume,""]);')
            }


        }

        public function unRegister():void
        {
            GameEventDispatch.instance.off(GameEvent.ScreenResize, this, screenResize);
            anchorPoint();
        }


        public function register():void
        {
            GameEventDispatch.instance.on(GameEvent.ScreenResize, this, screenResize);
        }




    }
}
