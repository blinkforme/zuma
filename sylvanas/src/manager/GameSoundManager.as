package manager
{

    import laya.media.SoundManager;


    public class GameSoundManager
    {
        public static var playInfo:Object = new Object();
        public static var playCache:Boolean = false;
        //声音播放间隔
        public static var soundInterval:Object =
                {
                    //                    "music/fish1_1.mp3": 5000,
                    //                    "music/fish1_2.mp3": 5000,
                    //                    "music/fish1_3.mp3": 5000,
                    //                    "music/fish1_4.mp3": 5000,

                };

        public static function getPlaySoundInterval(url:String):Number
        {
            //			if(soundInterval[url])
            //			{
            //				return soundInterval[url]
            //			}
            return 0;
        }

        private static var _playCache:Array = [];

        public static function playCacheSound(ignore:Boolean = false):void
        {
            playCache = false;
            //trace("playCacheSound begin");
            for (var i:int = 0; i < _playCache.length; i++)
            {
                playSound(_playCache[i]);
                //trace("playCacheSound", _playCache[i]);
            }
            //trace("playCacheSound end");
            _playCache.length = 0;
        }

        public static function playExcelMusic(str:String):void
        {
            var soundPath:String = ConfigManager.getConfValue("cfg_global", 1, str) as String;
            playSound(soundPath);
        }

        public static function playSound(url:String):void
        {
            var curMilli:Number = GameTools.now();

            if (!playInfo[url])
            {
                if (playCache)
                {
                    if (_playCache.indexOf(url) < 0)
                    {
                        _playCache.push(url);
                    }
                }
                else
                {
                    SoundManager.playSound(url);
                }
                playInfo[url] = curMilli;
            }
            else
            {
                if (curMilli - playInfo[url] >= getPlaySoundInterval(url))
                {
                    if (playCache)
                    {
                        if (_playCache.indexOf(url) < 0)
                        {
                            _playCache.push(url);
                        }
                    }
                    else
                    {
                        SoundManager.playSound(url);
                    }

                    playInfo[url] = curMilli;
                }
                else
                {

                }
            }

        }
    }
}
