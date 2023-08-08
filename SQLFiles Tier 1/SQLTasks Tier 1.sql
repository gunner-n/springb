/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

select distinct name from facilities where membercost > 0;

/* Q2: How many facilities do not charge a fee to members? */

select count(distinct name) from facilities where membercost = 0;

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
/*['facid', 'name', 'membercost', 'guestcost', 'initialoutlay', 'monthlymaintenance']*/

select facid, name, membercost, monthlymaintenance 
from facilities
where membercost < 0.2*monthlymaintenance;

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

select * from facilities where facid in (1,5);

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
select name, 
    monthlymaintenance,
    case when monthlymaintenance <= 100 then 'cheap'
    else 'expensive' end as maintenancecostcategory
from facilities 

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
/*['memid', 'surname', 'firstname', 'address', 'zipcode', 'telephone', 'recommendedby', 'joindate']*/
WITH joindtsort as 
    (select firstname, 
            surname, 
            rank () over (order by joindate desc) as rnk 
     from members)
select 
    firstname, 
    surname 
from joindtsort where rnk =1;


/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
/* booking table ['bookid', 'facid', 'memid', 'starttime', 'slots'] */

select 
    distinct m.firstname ||" "|| m.surname as membername,
    f.name as facilityname
from members m
    inner join 
    bookings b
    on m.memid = b.memid
    inner join 
    facilities f
    on b.facid = f.facid
where f.name like 'Tennis Court%'
order by membername;

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

select f.name,
       m.firstname || " " || m.surname as memname,
        case when b.memid = 0 then b.slots*f.guestcost
       else b.slots*f.membercost end as cost
from (select * from bookings where starttime like '2012-09-14%') b 
inner join facilities f
on b.facid = f.facid
inner join members m
on b.memid = m.memid
where cost > 30;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
select f.name,
       m.firstname || " " || m.surname as memname,
        case when b.memid = 0 then b.slots*f.guestcost
       else b.slots*f.membercost end as cost
from (select * from bookings where starttime like '2012-09-14%') b 
inner join facilities f
on b.facid = f.facid
inner join members m
on b.memid = m.memid
where cost > 30;

/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

with grain as (
    select f.name as facilityname,
    case when b.memid = 0 then b.slots*f.guestcost
       else b.slots*f.membercost end as cost
       from bookings b
       inner join facilities f
       on b.facid = f.facid
     )
select facilityname, sum(cost) as total_revenue
from grain
group by facilityname 
having total_revenue < 1000
order by total_revenue;


/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
select surname, firstname, recommendedby
from members 
order by surname, firstname;

/* Q12: Find the facilities with their usage by member, but not guests */
select distinct f.facid, name, m.memid, firstname, surname
from facilities f
inner join bookings b
on f.facid = b.facid
inner join members m
on b.memid = m.memid
where b.memid <> 0;

/* Q13: Find the facilities usage by month, but not guests */
select  f.facid, 
        f.name, 
        substr(b.starttime,6,2) as month, 
        sum(b.slots) as mem_slot_usage,
        sum(b.slots*f.membercost) as mem_cost
        from facilities as f
        inner join 
        (select * from bookings where memid <> 0) b
        on f.facid = b.facid
group by f.facid, f.name,month;


    
    



