function doGet() {

  // Open the spreadsheet by ID
  var spreadsheetId = 'PASTE_YOUR_SPREADSHEET_ID_HERE';
  var sheet = SpreadsheetApp.openById(spreadsheetId).getSheetByName('Sheet1'); // Change if necessary

  // Get the data range
  var data = sheet.getDataRange().getValues();

  // Log the raw data for debugging
  Logger.log("Raw Data: " + JSON.stringify(data));

  // Filter rows where status is 'online' or 'test-online' (case-insensitive)
  var filteredData = data.filter(function(row) {
    var status = row[1].toLowerCase(); // Convert status to lowercase
    return status === 'online' || status === 'test-online';
  });

  // Log the filtered data for debugging
  Logger.log("Filtered Data: " + JSON.stringify(filteredData));

  // Extract the Discord names (assuming they are in column A)
  var discordNames = filteredData.map(function(row) {
    return row[0];
  });

  // Log the Discord names for debugging
  Logger.log("Extracted Codes for discordNames: " + JSON.stringify(discordNames));

  // Extract the friend codes (assuming they are in column C)
  var friendCodes = filteredData.map(function(row) {
    return row[2];
  });

  // Log the friend codes for debugging
  Logger.log("Extracted Codes for friendCodes: " + JSON.stringify(friendCodes));

  // Extract the Discord IDs (assuming they are in column D)
  var discordIds = filteredData.map(function(row) {
    return row[3];
  });

  // Log the Discord IDs for debugging
  Logger.log("discordIds: " + JSON.stringify(discordIds));

  // Extract the instances list (assuming they are in column E)
  var instancesList = filteredData.map(function(row) {
    return row[4];
  });

  // Log the instances list for debugging
  Logger.log("instancesList: " + JSON.stringify(instancesList));

  // Get the total instances value from the spreadsheet (cell F2)
  var totalInstances = sheet.getRange(2, 6).getValue();

  // Log the total instances for debugging
  Logger.log("totalInstances: " + totalInstances);

  // Fixed headers to add before the lists
  var discordNameHeader = "DiscordNames";
  var friendCodeHeader = "FriendCodes";
  var discordIdHeader = "DiscordIDs";
  var totalInstancesHeader = "TotalInstances";

  // Create the final list with fixed separators
  var combinedList = [discordNameHeader].concat(discordNames, [friendCodeHeader], friendCodes, [discordIdHeader], discordIds, [totalInstancesHeader], [totalInstances]);

  // Log the final list
  Logger.log("combinedList: " + JSON.stringify(combinedList));

  return ContentService.createTextOutput(combinedList.join('\r\n')).setMimeType(ContentService.MimeType.TEXT);
}
