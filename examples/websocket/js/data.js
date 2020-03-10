var set = require('fuzzyset.js')();

[ "Alabama"
, "Alaska"
, "American Samoa"
, "Arizona"
, "Arkansas"
, "California"
, "Colorado"
, "Connecticut"
, "Delaware"
, "District of Columbia"
, "Florida"
, "Georgia"
, "Guam"
, "Hawaii"
, "Idaho"
, "Illinois"
, "Indiana"
, "Iowa"
, "Kansas"
, "Kentucky"
, "Louisiana"
, "Maine"
, "Maryland"
, "Massachusetts"
, "Michigan"
, "Minnesota"
, "Mississippi"
, "Missouri"
, "Montana"
, "Nebraska"
, "Nevada"
, "New Hampshire"
, "New Jersey"
, "New Mexico"
, "New York"
, "North Carolina"
, "North Dakota"
, "Northern Marianas Islands",
, "Ohio"
, "Oklahoma"
, "Oregon"
, "Pennsylvania"
, "Puerto Rico",
, "Rhode Island"
, "South Carolina"
, "South Dakota"
, "Tennessee"
, "Texas"
, "Utah"
, "Vermont"
, "Virginia"
, "Virgin Islands"
, "Washington"
, "West Virginia"
, "Wisconsin"
, "Wyoming"
].forEach(state => { set.add(state); })

module.exports = set;
