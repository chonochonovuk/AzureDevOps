#r "Newtonsoft.Json"

using System.Net;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Primitives;
using Newtonsoft.Json;
using System.Data.SqlClient;

public static async Task<IActionResult> Run(HttpRequest req, ILogger log)
{
    log.LogInformation("C# HTTP trigger function processed a request.");

    int? ID = Int32.Parse(req.Query["ID"]);
    string name = req.Query["name"];

    string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
    dynamic data = JsonConvert.DeserializeObject(requestBody);
    ID = ID ?? data?.ID;
    name = name ?? data?.name;

    if (ID != 0 && name != null)
    {
        // SQL Server DB connection string
        var str = "Server=tcp:http-triggers-sql-server.database.windows.net,1433;Initial Catalog=http-triggers-sql;Persist Security Info=False;User ID=chonoadmin;Password=******;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;";

        using (SqlConnection conn = new SqlConnection(str))
        {
            conn.Open();

            log.LogInformation("SQL query is " + ID + name);

             //SQL Insert statement 
             var insert = String.Format("INSERT INTO GuestList (ID, name, date) VALUES ({0}, '{1}', GETDATE())",ID,name);

            log.LogInformation("SQL query is " + insert);

            using (SqlCommand cmd = new SqlCommand(insert, conn))
            {
                int value = cmd.ExecuteNonQuery();
                if (value >= 0)
                {
                    return (ActionResult)new OkObjectResult(String.Format("Guest with ID {0} has checked in {1} time", ID, value));
                }                    
                else
                    return (ActionResult)new OkObjectResult("No guest has been updated " + name);
            }
        }
    }
    else 
        return new BadRequestObjectResult("Please pass a ID and name on the query string or in the request body");
}