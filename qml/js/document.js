var publicityRestrictions = {
    "Public": "MZ.publicityRestrictionsPublic",
    "Protected": "MZ.publicityRestrictionsProtected",
    "Private": "MZ.publicityRestrictionsPrivate"
}

var secureLevel = {
    "none": "MX.secureLevelNone",
    //"KM1": "MX.secureLevelKM1",
    //"KM5": "MX.secureLevelKM5",
    "KM10": "MX.secureLevelKM10",
    //"KM25": "MX.secureLevelKM25",
    //"KM50": "MX.secureLevelKM50",
    //"KM100": "MX.secureLevelKM100",
    //"Highest": "MX.secureLevelHighest",
    //"NoShow": "MX.secureLevelNoShow"
}

//var recordBasis = {
//    "Seen": "MY.recordBasisHumanObservationSeen",
//    "Heard": "MY.recordBasisHumanObservationHeard"
//}

var recordBasis = [
            "MY.recordBasisPreservedSpecimen",
            "MY.recordBasisHumanObservation",
            "MY.recordBasisHumanObservationPhoto",
            "MY.recordBasisHumanObservationHandled"
        ]

var taxonConfidence = {
    "Sure": "MY.taxonConfidenceSure",
    "Unsure": "MY.taxonConfidenceUnsure",
    "SubspeciesUnsure": "MY.taxonConfidenceSubspeciesUnsure"
}

function Document() {
    this.creator = ""
    this.editors = []
    this.formID = "JX.519"
    this.secureLevel = secureLevel.none
    this.publicityRestrictions = publicityRestrictions.Public
    this.gatherings = []
}

function GatheringEvent() {
    this.dateBegin = ""
    this.leg = []
    this.legPublic = true
    this.legUserID = []
    this.timeStart = ""
}

function Gathering() {
    this.coordinateSource = "MY.coordinateSourceGps"
    this.coordinateSystem = "MY.coordinateSystemWgs84"
    this.geometry = {
      "type": "Point",
      "coordinates": []
    }
    this.municipality = ""
    this.dateBegin = ""
    this.units = []
}

function Unit() {
    this.recordBasis = recordBasis.Seen
    this.identifications = []
    this.count = ""
    this.taxonConfidence = taxonConfidence.Sure
    this.notes = ""
}

function Identification() {
    this.taxon = ""
    this.taxonID = ""
}
