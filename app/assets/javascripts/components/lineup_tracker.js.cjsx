cx = React.addons.classSet
exports = exports ? this
exports.LineupTracker = React.createClass
  displayName: 'LineupTracker'

  #React callbacks
  getInitialState: () ->
    this.props = exports.wftda.functions.camelize(this.props)
    this.stateStack = []
    gameState: this.props
    selectorContext:
      roster: []
      buttonHandler: this.setSkater.bind(this, 0, 'away', 'pivot')
    selectedTeam: 'away'

  #Helper functions
  buildOptions: (opts = {}) ->
    stdOpts =
      role: 'Lineup Tracker'
      timestamp: Date.now
      state: this.state.gameState
      options: opts
    $.extend(stdOpts, opts)

  pushState: (eventName, eventOptions) ->
    this.stateStack.push
      gameState: $.extend(true, {}, this.state.gameState)
      eventName: eventName
      eventOptions: $.extend(true, {}, eventOptions)

  getJamState: (jamIndex, team) ->
    switch team
      when 'away' then this.state.gameState.awayAttributes.jamStates[jamIndex]
      when 'home' then this.state.gameState.homeAttributes.jamStates[jamIndex]

  getTeamAttributes: (team) ->
    switch team
      when 'away' then this.state.gameState.awayAttributes
      when 'home' then this.state.gameState.homeAttributes

  positionsInBox: (jam) ->
    positions = []
    for row in jam.lineupStatuses
      for position, status of row
        positions.push(position) if status in ['went_to_box', 'sat_in_box']
    positions

  getNewJam: (jamNumber) ->
    jamNumber: jamNumber
    noPivot: false
    starPass: false
    pivot: null
    blocker1: null
    blocker2: null
    blocker3: null
    jammer: null
    lineupStatuses: []


  statusTransition: (status) ->
    switch status
      when 'clear' then 'went_to_box'
      when 'went_to_box' then 'went_to_box_and_released'
      when 'went_to_box_and_released' then 'sat_in_box'
      when 'sat_in_box' then 'sat_in_box_and_released'
      when 'sat_in_box_and_released' then 'injured'
      when 'injured' then 'clear'
      else 'clear'

  #Display actions
  selectTeam: (team) ->
    this.state.selectedTeam = team
    this.setState(this.state)

  setSelectorContext: (jamIndex, teamType, position) ->
    team = this.getTeamAttributes(teamType)
    jam = this.getJamState(jamIndex, teamType)

    this.state.selectorContext = 
      roster: team.skaters.map (skater, skaterIndex) ->
        skaterPosition = switch skater
          when jam.pivot then 'pivot'
          when jam.blocker1 then 'blocker1'
          when jam.blocker2 then 'blocker2'
          when jam.blocker3 then 'blocker3'
          when jam.jammer then 'jammer'

        skater: skater
        isSelected: skaterPosition?
        isInjured: skaterPosition? and jam.lineupStatuses.some (lineupStatus) -> lineupStatus[skaterPosition] is 'injured'
      buttonHandler: this.setSkater.bind(this, jamIndex, teamType, position)
      style: team.colorBarStyle
    this.setState(this.state)

  #Data actions
  toggleNoPivot: (jamIndex, teamType) ->
    eventName = "lineup_tracker.toggle_no_pivot"
    eventOptions = this.buildOptions(
      jamIndex: jamIndex
      teamType: teamType
    )
    this.pushState(eventName, eventOptions)

    teamState = this.getJamState(jamIndex, teamType)
    teamState.noPivot = !teamState.noPivot
    this.setState(this.state)

    exports.dispatcher.trigger eventName, eventOptions

  toggleStarPass: (jamIndex, teamType) ->
    eventName = "lineup_tracker.toggle_star_pass"
    eventOptions = this.buildOptions(
      jamIndex: jamIndex
      teamType: teamType
    )
    this.pushState(eventName, eventOptions)

    teamState = this.getJamState(jamIndex, teamType)
    teamState.starPass = !teamState.starPass
    this.setState(this.state)

    exports.dispatcher.trigger eventName, eventOptions

  setSkater: (jamIndex, teamType, position, rosterIndex) ->
    eventName = "lineup_tracker.set_skater"
    eventOptions = this.buildOptions(
      jamIndex: jamIndex
      teamType: teamType
      position: position
      rosterIndex: rosterIndex
    )
    this.pushState(eventName, eventOptions)

    jamState = this.getJamState(jamIndex, teamType)
    teamAttributes = this.getTeamAttributes(teamType)
    jamState[position] = teamAttributes.skaters[rosterIndex]
    this.setState(this.state)

    exports.dispatcher.trigger eventName, eventOptions

  setLineupStatus: (jamIndex, teamType, statusIndex, position) ->
    eventName = "lineup_tracker.set_lineup_status"
    eventOptions = this.buildOptions(
      jamIndex: jamIndex
      teamType: teamType
      statusIndex: statusIndex
      position: position
    )
    this.pushState(eventName, eventOptions)

    teamState = this.getJamState(jamIndex, teamType)

    # Make a new row if need be
    if statusIndex >= teamState.lineupStatuses.length
      teamState.lineupStatuses[statusIndex] = {pivot: 'clear', blocker1: 'clear', blocker2: 'clear', blocker3: 'clear', jammer: 'clear', order: statusIndex }

    # Initialize position to clear
    if not teamState.lineupStatuses[statusIndex][position]
      teamState.lineupStatuses[statusIndex][position] = 'clear'

    currentStatus = teamState.lineupStatuses[statusIndex][position]
    teamState.lineupStatuses[statusIndex][position] = this.statusTransition(currentStatus)
    this.setState(this.state)

    exports.dispatcher.trigger eventName, eventOptions 

  endJam: (teamType) ->
    eventName="lineup_tracker.end_jam"
    eventOptions = this.buildOptions(
      teamType: teamType
    )
    this.pushState(eventName, eventOptions)

    team = this.getTeamAttributes(teamType)
    lastJam = team.jamStates[team.jamStates.length - 1]
    newJam = this.getNewJam(lastJam.jamNumber + 1)
    positionsInBox = this.positionsInBox(lastJam)
    if positionsInBox.length > 0
      newJam.lineupStatuses[0] = {}
      for position in positionsInBox
        newJam[position] = lastJam[position]
        newJam.lineupStatuses[0][position] = 'sat_in_box'
    team.jamStates.push(newJam)
    this.setState(this.state)

    exports.dispatcher.trigger eventName, eventOptions

  undo: () ->
    frame = this.stateStack.pop()
    if frame
      previousGameState = frame.gameState
      previousEventName = frame.eventName
      previousEventOptions = frame.eventOptions

      this.setState(gameState: previousGameState)
      exports.dispatcher.trigger previousEventName, previousEventOptions

  render: () ->
    homeActiveTeamClass = cx
      'hidden-xs': this.state.selectedTeam != 'home'

    awayActiveTeamClass = cx
      'hidden-xs': this.state.selectedTeam != 'away'

    <div className="lineup-tracker">
      <div className="row teams text-center gutters-xs">
        <div className="col-sm-6 col-xs-6">
          <button className="team-name btn btn-block" style={this.props.awayAttributes.colorBarStyle} onClick={this.selectTeam.bind(this, 'away')}>
            {this.props.awayAttributes.name}
          </button>
        </div>
        <div className="col-sm-6 col-xs-6">
          <button className="team-name btn btn-block" style={this.props.homeAttributes.colorBarStyle} onClick={this.selectTeam.bind(this, 'home')}>
            {this.props.homeAttributes.name}
          </button>
        </div>
      </div>
      <div className="active-team">
        <div className="row gutters-xs">
          <div className="col-sm-6 col-xs-6">
            <div className={awayActiveTeamClass}></div>
          </div>
          <div className="col-sm-6 col-xs-6">
            <div className={homeActiveTeamClass}></div>
          </div>
        </div>
      </div>
        <div className="row gutters-xs jam-details">
          <div className={awayActiveTeamClass + " col-sm-6 col-xs-12"} id="away-team">
            {this.state.gameState.awayAttributes.jamStates.map (jamState, jamIndex) ->
              <JamDetail
                key={jamIndex}
                teamAttributes={this.props.awayAttributes}
                jamState={jamState}
                noPivotHandler={this.toggleNoPivot.bind(this, jamIndex, 'away')}
                starPassHandler={this.toggleStarPass.bind(this, jamIndex, 'away')}
                lineupStatusHandler={this.setLineupStatus.bind(this, jamIndex, 'away')}
                setSelectorContextHandler={this.setSelectorContext.bind(this, jamIndex, 'away')}
                selectSkaterHandler={this.setSkater.bind(this, jamIndex, 'away')} />
            , this }
            <LineupTrackerActions endHandler={this.endJam.bind(this, 'away')} undoHandler={this.undo}/>
          </div>
          <div className={homeActiveTeamClass + " col-sm-6 col-xs-12"} id="home-team">
            {this.state.gameState.homeAttributes.jamStates.map (jamState, jamIndex) ->
              <JamDetail
                key={jamIndex}
                teamAttributes={this.props.homeAttributes}
                jamState={jamState}
                noPivotHandler={this.toggleNoPivot.bind(this, jamIndex, 'home')}
                starPassHandler={this.toggleStarPass.bind(this, jamIndex, 'home')}
                lineupStatusHandler={this.setLineupStatus.bind(this, jamIndex, 'home')}
                setSelectorContextHandler={this.setSelectorContext.bind(this, jamIndex, 'home')}
                selectSkaterHandler={this.setSkater.bind(this, jamIndex, 'home')} />
            , this }
            <LineupTrackerActions endHandler={this.endJam.bind(this, 'home')} undoHandler={this.undo}/>
          </div>
        </div>
      <SkaterSelectorDialog roster={this.state.selectorContext.roster} buttonHandler={this.state.selectorContext.buttonHandler} style={this.state.selectorContext.style} />
    </div>

exports.LineupTrackerActions = React.createClass
  displayName: 'LineupTrackerActions'
  propTypes:
    endHandler: React.PropTypes.func.isRequired
    undoHandler: React.PropTypes.func.isRequired

  render: () ->
    <div className="row gutters-xs actions">
        <div className="col-sm-6 col-xs-6">
          <button className="actions-action actions-edit text-center btn btn-block" onClick={this.props.endHandler}>
            END
          </button>
        </div>
        <div className="col-sm-6 col-xs-6">
          <button className="actions-action actions-undo text-center btn btn-block" onClick={this.props.undoHandler}>
            <strong>UNDO</strong>
          </button>
        </div>
      </div>

exports.JamDetail = React.createClass
  displayName: 'JamDetail'
  propTypes:
    teamAttributes: React.PropTypes.object.isRequired
    jamState: React.PropTypes.object.isRequired
    noPivotHandler: React.PropTypes.func.isRequired
    starPassHandler: React.PropTypes.func.isRequired
    lineupStatusHandler: React.PropTypes.func.isRequired
    setSelectorContextHandler: React.PropTypes.func.isRequired
    selectSkaterHandler: React.PropTypes.func.isRequired

  isInjured: (position) ->
    this.props.jamState.lineupStatuses.some (status) ->
      status[position] is 'injured'

  render: () ->
    noPivotButtonClass = cx
      'btn': true
      'btn-block': true
      'jam-detail-no-pivot': true
      'toggle-pivot-btn': true
      'selected': this.props.jamState.noPivot

    starPassButtonClass = cx
      'btn': true
      'btn-block': true
      'jam-detail-star-pass': true
      'toggle-star-pass-btn': true
      'selected': this.props.jamState.starPass

    actionsClass = cx
      'row': true
      'gutters-xs': true
      'actions': true

    <div>
      <div className="row gutters-xs jam-detail">
        <div className="col-sm-8 col-xs-8">
          <div className="jam-detail-number boxed-good">
            <div className="row gutters-xs">
              <div className="col-sm-11 col-xs-11 col-sm-offset-1 col-xs-offset-1">
                Jam {this.props.jamState.jamNumber}
              </div>
            </div>
          </div>
        </div>
        <div className="col-sm-2 col-xs-2">
          <button className={noPivotButtonClass} onClick={this.props.noPivotHandler}>
            <strong>No Pivot</strong>
          </button>
        </div>
        <div className="col-sm-2 col-xs-2">
          <button className={starPassButtonClass} onClick={this.props.starPassHandler}>
            <strong><span className="glyphicon glyphicon-star" aria-hidden="true"></span> Pass</strong>
          </button>
        </div>
      </div>
      <div className="row gutters-xs positions">
        <div className="col-sm-2 col-xs-2 col-sm-offset-2 col-xs-offset-2 text-center">
          <strong>Pivot</strong>
        </div>
        <div className="col-sm-2 col-xs-2 text-center">
          <strong>B1</strong>
        </div>
        <div className="col-sm-2 col-xs-2 text-center">
          <strong>B2</strong>
        </div>
        <div className="col-sm-2 col-xs-2 text-center">
          <strong>B3</strong>
        </div>
        <div className="col-sm-2 col-xs-2 text-center">
          <strong>J</strong>
        </div>
      </div>
      <div className="row gutters-xs skaters">
        <div className="col-sm-2 col-xs-2 col-sm-offset-2 col-xs-offset-2">
          <SkaterSelector skater={this.props.jamState.pivot} injured={this.isInjured('pivot')} style={this.props.teamAttributes.colorBarStyle} buttonHandler={this.props.setSelectorContextHandler.bind(this, "pivot")} />
        </div>
        <div className="col-sm-2 col-xs-2">
          <SkaterSelector skater={this.props.jamState.blocker1} injured={this.isInjured('blocker1')} style={this.props.teamAttributes.colorBarStyle} buttonHandler={this.props.setSelectorContextHandler.bind(this, "blocker1")} />
        </div>
        <div className="col-sm-2 col-xs-2">
          <SkaterSelector skater={this.props.jamState.blocker2} injured={this.isInjured('blocker2')} style={this.props.teamAttributes.colorBarStyle} buttonHandler={this.props.setSelectorContextHandler.bind(this, "blocker2")} />
        </div>
        <div className="col-sm-2 col-xs-2">
          <SkaterSelector skater={this.props.jamState.blocker3} injured={this.isInjured('blocker3')} style={this.props.teamAttributes.colorBarStyle} buttonHandler={this.props.setSelectorContextHandler.bind(this, "blocker3")} />
        </div>
        <div className="col-sm-2 col-xs-2">
          <SkaterSelector skater={this.props.jamState.jammer} injured={this.isInjured('jammer')} style={this.props.teamAttributes.colorBarStyle} buttonHandler={this.props.setSelectorContextHandler.bind(this, "jammer")} />
        </div>
      </div>
      {this.props.jamState.lineupStatuses.map (lineupStatus, statusIndex) ->
        <LineupBoxRow key={statusIndex} lineupStatus=lineupStatus lineupStatusHandler={this.props.lineupStatusHandler.bind(this, statusIndex)} /> 
      , this }
      <LineupBoxRow key={this.props.jamState.lineupStatuses.length} lineupStatusHandler={this.props.lineupStatusHandler.bind(this, this.props.jamState.lineupStatuses.length)} />
    </div>

exports.SkaterSelector = React.createClass
  displayName: 'SkaterSelector'
  propTypes:
    skater: React.PropTypes.object
    style: React.PropTypes.object
    buttonHandler: React.PropTypes.func.isRequired

  buttonContent: () ->
    if this.props.skater
      this.props.skater.number
    else
      <span className="glyphicon glyphicon-chevron-down" aria-hidden="true"></span>


  render: () ->
    injuryClass = cx
      'skater-injury': this.props.injured

    <button className={injuryClass + " skater-selector text-center btn btn-block"} data-toggle="modal" style={if this.props.skater and not this.props.injured then this.props.style else {}} data-target="#roster-modal" onClick={this.props.buttonHandler}>
      <strong>{this.buttonContent()}</strong>
    </button>

exports.SkaterSelectorDialog = React.createClass
  displayName: 'SkaterSelectorDialog'
  propTypes:
    roster: React.PropTypes.array.isRequired
    buttonHandler: React.PropTypes.func
    style: React.PropTypes.object

  getDefaultProps: () ->
    selectedSkaters: []
    injuredSkaters: []

  injuryClass: (rosterEntry) ->
    cx
      'selector-injury' : rosterEntry.isInjured

  render: () ->
    <div className="modal fade" id="roster-modal">
      <div className="modal-dialog skater-selector-dialog">
        <div className="modal-content">
          <div className="modal-header">
            <button type="button" className="close" data-dismiss="modal"><span>&times;</span></button>
            <h4 className="modal-title">Select Skater</h4>
          </div>
          <div className="modal-body">
            {this.props.roster.map (rosterEntry, rosterIndex) ->
                <button key={rosterIndex}
                  className={this.injuryClass(rosterEntry) + " btn btn-block skater-selector-dialog-btn"}
                  style={if rosterEntry.isSelected and not rosterEntry.isInjured then this.props.style}
                  data-dismiss="modal"
                  onClick={this.props.buttonHandler.bind(this, rosterIndex)}>
                    <strong className="skater-number">{rosterEntry.skater.number}</strong>
                    <strong className="skater-name">{rosterEntry.skater.name}</strong>
                </button>
            , this}
          </div>
        </div>
      </div>
    </div>

exports.LineupBoxRow = React.createClass
  displayName: 'LineupBoxRow'

  propTypes:
    lineupStatus: React.PropTypes.object

  getDefaultProps: () ->
    lineupStatus:
      pivot: 'clear'
      blocker1: 'clear'
      blocker2: 'clear'
      blocker3: 'clear'
      jammer: 'clear'

  render: () ->
    <div className="row gutters-xs boxes">
        <div className="col-sm-2 col-xs-2 col-sm-offest-2 col-xs-offset-2">
          <LineupBox status={this.props.lineupStatus.pivot} lineupStatusHandler={this.props.lineupStatusHandler.bind(this, 'pivot')} />
        </div>
        <div className="col-sm-2 col-xs-2">
          <LineupBox status={this.props.lineupStatus.blocker1} lineupStatusHandler={this.props.lineupStatusHandler.bind(this, 'blocker1')} />
        </div>
        <div className="col-sm-2 col-xs-2">
          <LineupBox status={this.props.lineupStatus.blocker2} lineupStatusHandler={this.props.lineupStatusHandler.bind(this, 'blocker2')} />
        </div>
        <div className="col-sm-2 col-xs-2">
          <LineupBox status={this.props.lineupStatus.blocker3} lineupStatusHandler={this.props.lineupStatusHandler.bind(this, 'blocker3')} />
        </div>
        <div className="col-sm-2 col-xs-2">
          <LineupBox status={this.props.lineupStatus.jammer} lineupStatusHandler={this.props.lineupStatusHandler.bind(this, 'jammer')} />
        </div>
      </div>


exports.LineupBox = React.createClass
  displayName: 'LineupBox'
  
  propTypes:
    status: React.PropTypes.string

  getDefaultProps: () ->
    status: 'clear'

  boxContent: () ->
    switch this.props.status
      when 'clear' then <span>&nbsp;</span>
      when null then <span>&nbsp;</span>
      when 'went_to_box' then '/'
      when 'went_to_box_and_released' then 'X'
      when 'injured' then <span className="glyphicon glyphicon-paperclip"></span>
      when 'sat_in_box' then  'S'
      when 'sat_in_box_and_released' then '$'

  render: () ->
    injuryClass = cx
      'box-injury': this.props.status is 'injured'

    <button className={injuryClass + " box text-center btn btn-block btn-box"} onClick={this.props.lineupStatusHandler}>
      <strong>{this.boxContent()}</strong>
    </button>

