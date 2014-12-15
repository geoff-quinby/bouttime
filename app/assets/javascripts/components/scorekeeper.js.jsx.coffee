cx = React.addons.classSet
exports = exports ? this
exports.Scorekeeper = React.createClass
  # click event handlers
  handleMainMenu: (e) ->
    console.log e.target
  handlePrev: (e) ->
    console.log e.target
  handleNext: (e) ->
    console.log e.target
  handleToggleTeam: (e) ->
    this.state.homeAttributes.isSelected = !this.state.homeAttributes.isSelected
    this.state.awayAttributes.isSelected = !this.state.awayAttributes.isSelected
    this.setState(this.state)

  getInitialState: () ->
    exports.wftda.functions.camelize(this.props)

  render: () ->
    homeActiveTeamClass = cx
      'home': true
      'hidden-xs': !this.state.homeAttributes.isSelected

    awayActiveTeamClass = cx
      'away': true
      'hidden-xs': !this.state.awayAttributes.isSelected

    `<div id="scorekeeper-view">
      <div className="row teams text-center gutters-xs">
        <div className="col-sm-6 col-xs-6">
          <div className="team-name" style={this.state.awayAttributes.colorBarStyle} onClick={this.handleToggleTeam}>
            {this.state.awayAttributes.name}
          </div>
        </div>
        <div className="col-sm-6 col-xs-6">
          <div className="team-name" style={this.state.homeAttributes.colorBarStyle} onClick={this.handleToggleTeam}>
            {this.state.homeAttributes.name}
          </div>
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
      <div className="row gutters-xs">
        <div className="col-sm-6 col-xs-12" id="away-team">
          <div className="row stats gutters-xs">
            <div className="col-sm-6 col-xs-6">
              <div className="stat current-jam">
                <div className="row gutters-xs">
                  <div className="col-sm-8 col-xs-8 col-sm-offset-1 col-xs-offset-1">
                    <strong>Current Jam</strong>
                  </div>
                  <div className="col-sm-2 col-xs-2 text-right current-jam-score">
                    <strong>{this.state.jamNumber}</strong>
                  </div>
                </div>
              </div>
            </div>
            <div className="col-sm-6 col-xs-6">
              <div className="stat game-total">
                <div className="row gutters-xs">
                  <div className="col-sm-8 col-xs-8 col-sm-offset-1 col-xs-offset-1">
                    <strong>Game Total</strong>
                  </div>
                  <div className="col-sm-2 col-xs-2 text-right game-total-score">
                    <strong>{this.state.awayAttributes.points}</strong>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div className="jams">
            <div className="headers">
              <div className="row gutters-xs">
                <div className="col-sm-2 col-xs-2">
                  <strong>Jam</strong>
                </div>
                <div className="col-sm-2 col-xs-2">
                  <strong>Skater</strong>
                </div>
                <div className="col-sm-2 col-xs-2 col-sm-offset-2 col-xs-offset-2 text-center">
                  <strong>Notes</strong>
                </div>
                <div className="col-sm-2 col-xs-2 col-sm-offset-2 col-xs-offset-2 text-center">
                  <strong>Points</strong>
                </div>
              </div>
            </div>
            <div className="columns">
              <div className="row gutters-xs">
                <div className="col-sm-2 col-xs-2">
                  <div className="jam text-center">
                    {this.state.jamNumber}
                  </div>
                </div>
                <div className="col-sm-2 col-xs-2">
                  <div className="skater">
                    {this.state.awayAttributes.jammerAttributes.number}
                  </div>
                </div>
                <div className="col-sm-2 col-xs-2">
                  <div className="notes injury text-center">
                    Injury
                  </div>
                </div>
                <div className="col-sm-2 col-xs-2">
                  <div className="notes call text-center">
                    Call
                  </div>
                </div>
                <div className="col-sm-2 col-xs-2">
                  <div className="notes lost text-center">
                    Lost
                  </div>
                </div>
                <div className="col-sm-2 col-xs-2">
                  <div className="points text-center">
                    10
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div className="links">
            <div className="row text-center gutters-xs">
              <div className="col-sm-6 col-xs-6">
                <div className="link main-menu" onClick={this.handleMainMenu}>
                  MAIN MENU
                </div>
              </div>
              <div className="col-sm-6 col-xs-6">
                <div className="row gutters-xs">
                  <div className="col-sm-5 col-xs-5 col-sm-offset-1 col-xs-offset-1">
                    <div className="link prev" onClick={this.handlePrev}>
                      PREV
                    </div>
                  </div>
                  <div className="col-sm-6 col-xs-6">
                    <div className="link next" onClick={this.handleNext}>
                      NEXT
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div className="jam-details">
            <div className="row gutters-xs">
              <div className="col-sm-3 col-xs-3 col-sm-offset-6 col-xs-offset-6">
                <div className="jam-number">
                  <strong>Jam 5</strong>
                </div>
              </div>
              <div className="col-sm-3 col-xs-3 text-right">
                <div className="jam-total-score">
                  <strong>0</strong>
                </div>
              </div>
            </div>
          </div>
          <PassesList passes={this.state.awayAttributes.passStates} teamType="away" />
        </div>
        <div className="col-sm-6 col-xs-12 hidden-xs" id="home-team">
          <div className="row stats gutters-xs">
            <div className="col-sm-6 col-xs-6">
              <div className="stat current-jam">
                <div className="row gutters-xs">
                  <div className="col-sm-8 col-xs-8 col-sm-offset-1 col-xs-offset-1">
                    <strong>Current Jam</strong>
                  </div>
                  <div className="col-sm-2 col-xs-2 text-right current-jam-score">
                    <strong>{this.state.jamNumber}</strong>
                  </div>
                </div>
              </div>
            </div>
            <div className="col-sm-6 col-xs-6">
              <div className="stat game-total">
                <div className="row gutters-xs">
                  <div className="col-sm-8 col-xs-8 col-sm-offset-1 col-xs-offset-1">
                    <strong>Game Total</strong>
                  </div>
                  <div className="col-sm-2 col-xs-2 text-right game-total-score">
                    <strong>{this.state.homeAttributes.points}</strong>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div className="jams">
            <div className="headers">
              <div className="row gutters-xs">
                <div className="col-sm-2 col-xs-2">
                  <strong>Jam</strong>
                </div>
                <div className="col-sm-2 col-xs-2">
                  <strong>Skater</strong>
                </div>
                <div className="col-sm-2 col-xs-2 col-sm-offset-2 col-xs-offset-2 text-center">
                  <strong>Notes</strong>
                </div>
                <div className="col-sm-2 col-xs-2 col-sm-offset-2 col-xs-offset-2 text-center">
                  <strong>Points</strong>
                </div>
              </div>
            </div>
            <div className="columns">
              <div className="row gutters-xs">
                <div className="col-sm-2 col-xs-2">
                  <div className="jam text-center">
                    1
                  </div>
                </div>
                <div className="col-sm-2 col-xs-2">
                  <div className="skater">
                    1234
                  </div>
                </div>
                <div className="col-sm-2 col-xs-2">
                  <div className="notes injury text-center">
                    Injury
                  </div>
                </div>
                <div className="col-sm-2 col-xs-2">
                  <div className="notes call text-center">
                    Call
                  </div>
                </div>
                <div className="col-sm-2 col-xs-2">
                  <div className="notes lost text-center">
                    Lost
                  </div>
                </div>
                <div className="col-sm-2 col-xs-2">
                  <div className="points text-center">
                    10
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div className="links">
            <div className="row text-center gutters-xs">
              <div className="col-sm-6 col-xs-6">
                <div className="link main-menu">
                  MAIN MENU
                </div>
              </div>
              <div className="col-sm-6 col-xs-6">
                <div className="row gutters-xs">
                  <div className="col-sm-5 col-xs-5 col-sm-offset-1 col-xs-offset-1">
                    <div className="link prev">
                      PREV
                    </div>
                  </div>
                  <div className="col-sm-6 col-xs-6">
                    <div className="link next">
                      NEXT
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div className="jam-details">
            <div className="row gutters-xs">
              <div className="col-sm-3 col-xs-3 col-sm-offset-6 col-xs-offset-6">
                <div className="jam-number">
                  <strong>Jam 5</strong>
                </div>
              </div>
              <div className="col-sm-3 col-xs-3 text-right">
                <div className="jam-total-score">
                  <strong>0</strong>
                </div>
              </div>
            </div>
          </div>
          <PassesList passes={this.state.homeAttributes.passStates} teamType="home" />
        </div>
      </div>
    </div>`
