using System;
using System.IO;
using System.Diagnostics;

class Program
{
    static void Main()
    {
        string documentsPath = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments);
        string scriptLogPath = Path.Combine(documentsPath, "script_log.txt");
        string batFilePath = Path.Combine(documentsPath, "DailyUsageLimit.bat");

        using (StreamWriter writer = new StreamWriter(scriptLogPath, true))
        {
            writer.WriteLine("Log entry at " + DateTime.Now);
        }

        CallScript(batFilePath, scriptLogPath);
    }

    static void CallScript(string batFilePath, string scriptLogPath)
    {
        try
        {
            Process process = new Process();
            ProcessStartInfo startInfo = new ProcessStartInfo()
            {
                WindowStyle = ProcessWindowStyle.Hidden,
                FileName = "cmd.exe",
                Arguments = String.Format("/C \"{0}\"", batFilePath),
                UseShellExecute = false,
                RedirectStandardOutput = true,
                CreateNoWindow = true
            };
            process.StartInfo = startInfo;
            process.Start();
            string output = process.StandardOutput.ReadToEnd();
            process.WaitForExit();

            using (StreamWriter writer = new StreamWriter(scriptLogPath, true))
            {
                writer.WriteLine("Output from batch file: " + output);
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine("Error running script: " + ex.Message);
            using (StreamWriter writer = new StreamWriter(scriptLogPath, true))
            {
                writer.WriteLine("Error: " + ex.Message);
            }
        }
    }
}
