package fight
{
    public class CachePool
    {
        private static var _cacheInfo:Object = {};

        public static function Cache(name:String, key:String, obj:*):void
        {
            if (!_cacheInfo[name])
            {
                if (key)
                {
                    _cacheInfo[name] = {};
                    _cacheInfo[name][key] = [];
                }
                else
                {
                    _cacheInfo[name] = [];
                }
            }
            if (key)
            {
                if (!_cacheInfo[name][key])
                {
                    _cacheInfo[name][key] = [];
                }
                _cacheInfo[name][key].push(obj);
            }
            else
            {
                _cacheInfo[name].push(obj);
            }
        }

        public static function GetCache(name:String, key:String, classDef:*):*
        {
            ret = new classDef();
            return ret;

            var ret:* = null;

            if (_cacheInfo[name])
            {
                var tmpArray:Array = _cacheInfo[name];
                if (key)
                {
                    tmpArray = _cacheInfo[name][key];
                }
                if (tmpArray && tmpArray.length > 0)
                {
                    ret = tmpArray[0];
                    tmpArray.splice(0, 1);
                }
            }
            if (!ret)
            {
                ret = new classDef();
            }

            return ret;
        }

    }
}