using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

using DataAccessLayer;
using System.Collections;

namespace EmployeeProjectsManager
{
    public partial class FormManager : Form
    {
        public FormManager()
        {
            InitializeComponent();
        }

        private void tabPageEPH_Enter(object sender, EventArgs e)
        {       
            EmployeeProjectHour objEPH = new EmployeeProjectHour();
            dataGridViewEPH.DataSource = objEPH.SelEmployeeProjectHour().ToList();

        }

    }
}
