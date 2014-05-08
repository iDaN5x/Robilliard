function [conn] = connectToDatabase()

% ============================= About =================================
% This function connects to a certain database (our database), and
% returns the connection object.
%
% To use this function with other databases change those variables:
% > dbname (the name of the database).
% > username (the username to connect to your database).
% > password (the password to connect to your database).
% > dburl (your database server url address).
%
% Only change javaclasspath if the mysql-java-connector directory path
% is different in your computer.
%
% =====================================================================

dbname = 'sql28217';
username = 'sql28217';
password = 'lS6*jZ5*';
driver = 'com.mysql.jdbc.Driver';
dburl = ['jdbc:mysql://sql2.freemysqlhosting.net:3306/' dbname];

javaclasspath('C:\Program Files\MySQL\Connector J 5.1.24\mysql-connector-java-5.1.24-bin.jar');

conn = database(dbname, username, password, driver, dburl);

end