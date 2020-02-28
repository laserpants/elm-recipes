'use strict';

module.exports = function(storageKey) {
  var initSessionStorage = function(app) {
    if (app.ports && app.ports.setSession) {
      app.ports.setSession.subscribe(function(data, usePersistent) {
        if ('function' === typeof(usePersistent)) {
          var storageApi = usePersistent(data) ? localStorage : sessionStorage;
          storageApi.setItem(storageKey, JSON.stringify(data));
        } else {
          sessionStorage.setItem(storageKey, JSON.stringify(data));
        }
      });
    }

    if (app.ports && app.ports.clearSession) {
      app.ports.clearSession.subscribe(function(data) {
        localStorage.removeItem(storageKey);
        sessionStorage.removeItem(storageKey);
      });
    }
  }

  var getItem = function() {
    return sessionStorage.getItem(storageKey) || localStorage.getItem(storageKey) || '';
  }

  return { initSessionStorage, getItem };
};
