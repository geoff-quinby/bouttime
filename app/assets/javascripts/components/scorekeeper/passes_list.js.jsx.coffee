exports = exports ? this
exports.PassesList = React.createClass
  render: () ->
    console.log this.props
    PassItemFactory = React.createFactory(PassItem)
    passComponents = this.props.passes.map (pass) =>
      PassItemFactory(
        key: pass.number
        pass: pass
        teamType: this.props.teamType
        roster: this.props.roster
      )
    passComponents.push(
      PassItemFactory(
        key: "0"
        pass: {passNumber: this.props.passes.length+1 }
        teamType: this.props.teamType
        roster: this.props.roster
      )
    )

    `<div className="passes">
      <div className="headers">
        <div className="row gutters-xs">
          <div className="col-sm-2 col-xs-2">
            Pass
          </div>
          <div className="col-sm-2 col-xs-2">
            Skater
          </div>
          <div className="col-sm-2 col-xs-2"></div>
          <div className="col-sm-2 col-xs-2 text-center">
            Notes
          </div>
          <div className="col-sm-2 col-xs-2"></div>
          <div className="col-sm-2 col-xs-2 text-center">
            Points
          </div>
        </div>
      </div>
      {passComponents}
    </div>`
