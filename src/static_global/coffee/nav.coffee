class SideBarNav
  constructor: ->
    @hamburgerEl = document.querySelector('.xsd-nav-app__hamburger')
    @pageTitle   = document.querySelector('.xsd-nav-app__title')
    @sideNavEl   = document.querySelector('.xsd-nav-app__nav')
    @sideNavInnerEl = document.querySelector('.xsd-nav-app__nav-inner')
    @blurEl      = document.querySelector('.xsd-nav-app__blur')

    @touchingSideNav = false
    @doingInertialScroll = false
    @startX = 0
    @currentX = 0
    @startY = 0
    @currentY = 0
    @currentYTranslate = 0
    @translateY = 0
    @spreadY = 0
    @lastTranslateY = 0
    @startTimestamp = null
    @animationLength = null

    @minLimitY = 0
    @maxLimitY

    @hamburgerEl.addEventListener('click', @showNav)
    @pageTitle.addEventListener('click', @showNav)
    @blurEl.addEventListener('click', @hideViaBlur)

    document.addEventListener('touchstart', @onTouchStart)
    document.addEventListener('touchmove', @onTouchMove)
    document.addEventListener('touchend', @onTouchEnd)

    @sideBarAppSelection = new SideBarAppSelection(@)
    @sideBarModuleNavigation = new SideBarModuleNavigation(@)

  calcLimitY: ->
    @maxLimitY = - Math.max(@sideNavInnerEl.offsetHeight - 200, 0)

  showNav: =>
    @sideNavEl.classList.add('xsd-nav-app__nav--visible')
    @sideNavEl.classList.add('xsd-nav-app__nav--animate')
    @blurEl.classList.add('xsd-nav-app__blur--visible')

    # Fix #279, uses BS class on body to do this
    $(document.body).addClass('modal-open')

  hideViaBlur: (e) =>
    # Prevent clicking things under the blur
    e.preventDefault()
    @hideNav()

  hideNav: =>
    @sideNavEl.classList.remove('xsd-nav-app__nav--visible')
    @blurEl.classList.remove('xsd-nav-app__blur--visible')
    @sideBarAppSelection.reset()

    # Fix #279, uses BS class on body to do this
    $(document.body).removeClass('modal-open')

  onTouchStart: (e) =>
    if not @sideNavEl.classList.contains('xsd-nav-app__nav--visible')
      return
    else
      e.preventDefault()

    @sideNavEl.classList.remove('xsd-nav-app__nav--animate')
    @sideNavInnerEl.classList.remove('xsd-nav-app__nav-inner--animate')

    e.preventDefault()

    @startX = e.touches[0].pageX
    @startY = e.touches[0].pageY
    @currentX = @startX
    @currentY = @startY
    @currentYTranslate = @startY + @lastTranslateY
    @touchingSideNav = true

    @calcLimitY()

    requestAnimationFrame(@update)

  onTouchMove: (e) =>
    if not @touchingSideNav
      return
    else
      e.preventDefault()

    lastY = @currentY

    @currentX = e.touches[0].pageX
    @currentY = e.touches[0].pageY
    @currentYTranslate = e.touches[0].pageY + @lastTranslateY

    @spreadY = @currentY - lastY

  onTouchEnd: (e) =>
    if not @touchingSideNav
      return
    else
      e.preventDefault()

    @sideNavEl.classList.add('xsd-nav-app__nav--animate')

    if @currentX - @startX < -50
      @hideNav()

    @touchingSideNav = false
    @sideNavEl.style.transform = ""
    # Inertial scrolling
    @sideNavInnerEl.classList.add('xsd-nav-app__nav-inner--animate')
    inertialScrollY = @translateY + Math.min(250, Math.pow(1.2, @spreadY) + 3*@spreadY)
    @setTranslateY(inertialScrollY, true)
    @lastTranslateY = @translateY

    # Click detection
    if Math.abs(@currentX - @startX) + Math.abs(@currentY - @startY) < 3
      window.e = e
      @sideBarAppSelection.touchEvent(e)
      @sideBarModuleNavigation.touchEvent(e)
      @touchEvent(e)

  touchEvent: ->
    elem = e.srcElement
    if elem.classList.contains('xsd-nav-app__blur')
      @hideNav()

  update: =>
    if not @touchingSideNav
      return

    requestAnimationFrame(@update)

    translateX = Math.min(0, @currentX - @startX)
    if translateX < -10 or @sideNavEl.style.transform != ""
      @sideNavEl.style.transform = "translateX(#{translateX}px)"

    @setTranslateY(@currentYTranslate - @startY)

  setTranslateY: (y, limits=false) ->
    if limits
      y = Math.min(@minLimitY, y)
      y = Math.max(@maxLimitY, y)
    @translateY = y
    @sideNavInnerEl.style.transform = "translateY(#{y}px)"

  scrollTo: (elem) ->
    if @touchingSideNav
      return
    @sideNavInnerEl.classList.add('xsd-nav-app__nav-inner--animate')

    @calcLimitY()

    @translateY = -elem.offsetTop
    @lastTranslateY = @translateY
    @setTranslateY(@translateY, true)


class SideBarAppSelection
  constructor: (sideBarNav) ->
    @sideBarNav = sideBarNav

    @allAppNodes     = document.querySelectorAll('.xsd-nav-app__nav-item')
    @currentAppNode  = document.querySelector('.xsd-nav-app__nav-item.active')
    if @currentAppNode
      @currentAppName = @currentAppNode.dataset.appName

    for appNode in @allAppNodes
      appNode.querySelector('a').addEventListener('click', @tapApp)
      moduleNode = @getModuleNode(appNode)
      # TODO: BS4 defudge Why are we getting the height of something that is hidden, it won't work! How did this even work before?
      moduleNode.dataset.fullHeight = moduleNode.getClientRects()[0].height

      unless appNode.classList.contains('selected')
        moduleNode.style.maxHeight = 0

  getModuleNode: (appNode) ->
    appNode.querySelector('.xsd-nav-app__nav-module')

  tapApp: (e) =>
    e.preventDefault()
    appName = e.srcElement.parentElement.dataset.appName
    @selectApp(appName)

  touchEvent: (e) ->
    elem = e.srcElement
    if elem.parentElement.dataset.appName == 'xsd-dashboard'
      @sideBarNav.hideNav()
      window.activitySpinner.showSpinner()
      window.location = elem.href
    else if elem.classList.contains('xsd-nav-app__nav-link')
      @selectApp(elem.parentElement.dataset.appName)

  selectApp: (appName) =>
    for appNode in @allAppNodes
      moduleNode = @getModuleNode(appNode)
      if appNode.dataset.appName == appName
        appNode.classList.add('selected')
        @currentAppNode = appNode
        moduleNode.style.maxHeight = "#{moduleNode.dataset.fullHeight}px"
      else
        appNode.classList.remove('selected')
        moduleNode.style.maxHeight = 0
    setTimeout =>
      @sideBarNav.scrollTo(@currentAppNode)
    , 100 + 60 # Need to wait for CSS transition because we need to know the height. Add some ms to account for delays
    return @currentAppNode

  reset: ->
    if @currentAppName
      @selectApp(@currentAppName)

class SideBarModuleNavigation
  constructor: (sideBarNav) ->
    @sideBarNav = sideBarNav

  touchEvent: (e) =>
    elem = e.srcElement
    if elem.classList.contains('xsd-nav-module__link-text')
      @sideBarNav.hideNav()
      window.activitySpinner.showSpinner()
      window.location = elem.parentElement.href

$(document).ready ->
  console.log window.detectMQ('sm')
  if window.detectMQ('sm') and document.getElementById('xsd-nav-app')
    $('.xsd-nav-app__nav-item-xsd_auth').removeClass('dropdown')
    $('.xsd-nav-app__nav-item-xsd_auth .xsd-nav-app__nav-module').removeClass('dropdown-menu')
    sideBarNav = new SideBarNav()
    window.sideBarNav = sideBarNav
    #sideBarNav.showNav()
