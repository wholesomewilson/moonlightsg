function urlB64ToUint8Array(base64String) {
  const padding = '='.repeat((4 - base64String.length % 4) % 4);
  const base64 = (base64String + padding)
    .replace(/\-/g, '+')
    .replace(/_/g, '/');

  const rawData = window.atob(base64);
  const outputArray = new Int8Array(rawData.length);

  for (let i = 0; i < rawData.length; ++i) {
    outputArray[i] = rawData.charCodeAt(i);
  }
  return outputArray;
}

function register(resolve){
  if (navigator.serviceWorker) {
    navigator.serviceWorker.getRegistrations().then(function(registration) {
      if(registration.length > 0){
        registration[0].update()
        console.log("update success")
        navigator.serviceWorker.register('/serviceworker.js')
        .then(function(reg) {
          console.log('Service worker change, registered the service worker');
          subscription(resolve)
        })
      }
      else{
        navigator.serviceWorker.register('/serviceworker.js')
        .then(function(reg) {
          console.log('Service worker change, registered the service worker');
          subscription(resolve)
        })
      }
    });
  }
  else{
    console.error('Service worker is not supported in this browser');
  }
}

function subscription(resolve){
  navigator.serviceWorker.ready
  .then(function(reg) {
    reg.pushManager.getSubscription()
    .then(function(sub){
      var vapid_public = urlB64ToUint8Array($('meta[name="vapid-public"]').attr('content'))
      var options = {
        userVisibleOnly: true,
        applicationServerKey: vapid_public
      };
      if(sub == null){
        console.log(reg.scope)
        reg.pushManager.subscribe(options).then(
          function(pushSubscription) {
            console.log(pushSubscription)
            console.log(vapid_public)
            let body = pushSubscription.toJSON()
            $('#user_endpoint').val(body.endpoint)
            $('#user_p256dh').val(body.keys.p256dh)
            $('#user_auth').val(body.keys.auth)
            console.log("You've successfully subscribed")
            console.log(pushSubscription.toJSON());
            resolve()
          },function(error) {
              console.log(error);
            }
        )
      }else{
        reg.pushManager.getSubscription().then(function(sub) {
          console.log(sub)
          sub.unsubscribe().then(function(successful) {
            console.log("You've successfully unsubscribed "+ successful)
            reg.pushManager.subscribe(options).then(
              function(pushSubscription) {
                console.log(vapid_public)
                let body = pushSubscription.toJSON()
                return body
                console.log("You've successfully subscribed " + pushSubscription.toJSON())
                console.log(pushSubscription.toJSON());
              },function(error) {
                  console.log(error);
                }
            ).then(function(body){
              $('#user_endpoint').val(body.endpoint)
              $('#user_p256dh').val(body.keys.p256dh)
              $('#user_auth').val(body.keys.auth)
              resolve()
            })
          }).catch(function(e) {
            console.log("Unsubscription failed")
          })
        })
      }
    })
  });
}
