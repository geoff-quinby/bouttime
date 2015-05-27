jest.dontMock '../app/scripts/components/scoreboard'
jest.dontMock '../app/scripts/demo_data'

React = require 'react/addons'
Scoreboard = require '../app/scripts/components/scoreboard'
TestUtils = React.addons.TestUtils
DemoData = require '../app/scripts/demo_data'

describe 'Scoreboard', () ->
  gameState = null
  scoreboard = null
  beforeEach () ->
    gameState = DemoData.init()
    scoreboard = TestUtils.renderIntoDocument <Scoreboard gameState={gameState} />    
  it 'renders a component', () ->
    expect(TestUtils.isDOMComponent(scoreboard.getDOMNode()))
  it "displays team names", () ->
  it "displays team logos", () ->
  it "displays the current jam number", () ->
  it "displays the current period", () ->
  it "displays the team scores", () ->
