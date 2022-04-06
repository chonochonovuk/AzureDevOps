#r "Newtonsoft.Json"

using System.Net;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Primitives;
using Newtonsoft.Json;
using System.Data.SqlClient;

public static async Task<IActionResult> Run(HttpRequest req, ILogger log)
{
    log.LogInformation("C# HTTP trigger function processed a request.");

    string guestName = req.Query["guestName"];

    string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
    dynamic data = JsonConvert.DeserializeObject(requestBody);
    
    guestName = guestName ?? data?.guestName;

    if (guestName != null)
    {
        // SQL Server DB connection string
        var str = "Server=tcp:http-triggers-sql-server.database.windows.net,1433;Initial Catalog=http-triggers-sql;Persist Security Info=False;User ID=chonoadmin;Password=8888888;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;";

        using (SqlConnection conn = new SqlConnection(str))
        {
            conn.Open();

            log.LogInformation("You query is for :" + guestName);

             //SQL Insert statement 
             var query = String.Format("SELECT TOP(1) ID, name, date FROM GuestList WHERE name = '{0}'", guestName);

            log.LogInformation("SQL query is " + query);

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    reader.Read();
                    return (ActionResult)new OkObjectResult(String.Format("Guest with ID - {0} and name - {1} has checked in at {2} .", reader[0], reader[1], reader[2]));
                }                    
                else
                    return (ActionResult)new OkObjectResult("No guest with name - " + guestName);
            }
        }
    }
    else 
        return new BadRequestObjectResult("Please pass a guestName on the query string or in the request body");
}