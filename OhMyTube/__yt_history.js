window.__yt_history || (function(window, history, protocol) {
                        
                        var __yt_history = window.__yt_history = {};
                        window.__yt_history_hashchange_listen = true;
                        
                        var addEvent = function(element, event, handler) {
                        element.addEventListener(event, handler, false);
                        },
                        removeEvent = function(element, event, handler) {
                        element.removeEventListener(event, handler, false);
                        },
                        isLink = function(el) {
                        return el.href && el.tagName.toLowerCase() === 'a' && el.target === '_blank';
                        },
                        getLink = function(el) {
                        if(isLink(el)) {
                        return el;
                        }
                        
                        while(el = el.parentNode) {
                        if(isLink(el)) {
                        return el;
                        }
                        }
                        
                        return null;
                        },
                        appRequest = function(url) {
                        webkit.messageHandlers.PushStateChanged.postMessage(url);
                        },
                        cur_href = function() {
                        return window.location.href
                        .replace('#', encodeURIComponent('#'))
                        .replace('?', encodeURIComponent('?'));
                        },
                        onhashchange = function() {
                        window.__yt_history_hashchange_listen && setTimeout(function() {
                                                                            appRequest('pushstate?' + cur_href());
                                                                            }, 0);
                        };
                        
                        addEvent(window, 'hashchange', onhashchange);
                        
                        window.__yt_history_hashchangeStop = function() {
                        window.__yt_history_hashchange_listen = false;
                        //removeEvent(window, 'hashchange', onhashchange);
                        };
                        
                        window.__yt_history_hashchangeStart = function() {
                        window.__yt_history_hashchange_listen = true;
                        };
                        
                        
                        var history_methods = ['go', 'back', 'forward', 'pushState', 'replaceState'];
                        history_methods.forEach(function(method_name) {
                                                var method_key = 'on' + method_name.toLowerCase(),
                                                method = history[method_name];
                                                
                                                history[method_name] = function() {          
                                                var result = method.apply(history, arguments);
                                                
                                                if(typeof __yt_history[method_key] === 'function') {
                                                __yt_history[method_key].apply(history, arguments);
                                                }
                                                
                                                return result;
                                                };
                                                });
                        
                        __yt_history.ongo = function(offset) {
                        appRequest('go?' + offset);
                        };
                        
                        __yt_history.onback = function() {
                        __yt_history.ongo(-1);
                        };
                        
                        __yt_history.onforward = function() {
                        __yt_history.ongo(1);
                        };
                        
                        __yt_history.onpushstate = function(state, title, url) {
                        appRequest('pushstate?' + cur_href());
                        };
                        
                        __yt_history.onreplacestate = function(state, title, url) {
                        appRequest('replacestate?' + cur_href());
                        };
                        
                        addEvent(window, 'load', function() {
                                 appRequest('load?' + cur_href());
                                 });
                        
                        addEvent(window, 'unload', function() {    
                                 appRequest('unload?' + cur_href());
                                 });
                        
                        })(this, this.history, '');