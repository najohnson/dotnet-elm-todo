using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.HttpsPolicy;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Pomelo.EntityFrameworkCore.MySql.Infrastructure;
using TodoApi.Models;

namespace TodoApi
{
    public class Startup
    {
        private string _server { get; set; } = "localhost";
        private string _db { get; set; } = "Todo";
        private string _user { get; set; } = "root";
        private string _pass { get; set; } = "localhost";

        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;

            // There's probably a better way to do this
            var value = "";
            value = Environment.GetEnvironmentVariable("DB_HOST");
            if (value != null) {
                _server = value;
            }
            value = Environment.GetEnvironmentVariable("DB_DATABASE");
            if (value != null) {
                _db = value;
            }
            value = Environment.GetEnvironmentVariable("DB_USER");
            if (value != null) {
                _user = value;
            }
            value = Environment.GetEnvironmentVariable("DB_PASS");
            if (value != null) {
                _pass = value;
            }
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            // services.AddDbContext<TodoContext>(opt =>
            //     opt.UseInMemoryDatabase("TodoList"));
        
            // Setup the DB connection
            services.AddDbContextPool<TodoContext>(
                options => options.UseMySql($"Server={_server};Database={_db};User={_user};Password={_pass};",
                    mySqlOptions =>
                    {
                        mySqlOptions.ServerVersion(new Version(8, 0, 14), ServerType.MySql); // replace with your Server Version and Type
                    }
            ));
            
            services.AddMvc().SetCompatibilityVersion(CompatibilityVersion.Version_2_2);
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            else
            {
                // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
                app.UseHsts();
            }

            app.UseHttpsRedirection();
            app.UseMvc();

            // For the static app
            app.UseDefaultFiles();
            app.UseStaticFiles();
        }
    }
}
