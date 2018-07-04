--������� ������� � ������ � ������� ������ � ��������

create table goods_type
(
id_type int not null primary key identity(1,1) ,
name_type nvarchar(50) not null ,
);

insert into goods_type(name_type)
values ('��������');
insert into goods_type(name_type)
values ('���������');
insert into goods_type(name_type)
values ('����������');


create table goods
(
id_goods int not null primary key identity(1,1) ,
name_goods nvarchar(50) not null,
id_type int not null,
quantity int not null check(quantity>=0),
cost int not null
);

insert into goods(name_goods, id_type, quantity, cost)
values ('��������', 1, 22, 6000);
insert into goods(name_goods, id_type, quantity, cost)
values ('�������', 1, 14, 3000);
insert into goods(name_goods, id_type, quantity, cost)
values ('����', 1, 12, 17000);
insert into goods(name_goods, id_type, quantity, cost)
values ('����� �� ����', 2, 20, 1500);
insert into goods(name_goods, id_type, quantity, cost)
values ('�������� �', 2, 17, 2200);
insert into goods(name_goods, id_type, quantity, cost)
values ('����� ��� ����', 2, 16, 700);
insert into goods(name_goods, id_type, quantity, cost)
values ('������� ��� �����', 3, 45, 3700);
insert into goods(name_goods, id_type, quantity, cost)
values ('������� ��� �����', 3, 34, 4500);
insert into goods(name_goods, id_type, quantity, cost)
values ('������� ��� �����', 3, 47, 6000);


create table client 
(
id_client int not null primary key,
name_client nvarchar(50) not null,
id_discount_card int unique not null identity(100001,1),
percentage_card int not null,
total_amount int not null
);
 

create table order_zoo
(
id_order int not null,
id_goods int not null ,
id_client int not null ,
qtu int not null default 1,
payment_method nvarchar(50) not null check (payment_method in ('cash','card')),
date_order date default getdate() 
);
 
create table boxoffice
(
id_box int not null unique,
id_client int not null,
amount int,
amount_discount int,
delivery nvarchar(50) not null default 'no' check (delivery in ('yes','no')),
date_box date default getdate() 
);

--������� ��������: 1. �������� ������� ������ �� ������; 2.���������� ��� ��������� 
--������(��������� ���� ������) � ������� � ��������� ����
create trigger trigger_insert_order
on order_zoo for insert
as
declare @x int, @y int, @qtu_inserted int, @qtu_instock int
select @qtu_inserted=i.qtu, @qtu_instock = g.quantity 
from goods g,inserted i
where g.id_goods=i.id_goods
if @@rowcount=1
--� ������� order_zoo ����������� ������ � ������� ������
begin
--���������� ���������� ������ ������ ���� �� ������, ��� ��� ������� �� ������� goods
if @qtu_inserted>@qtu_instock
    begin
       rollback transaction
         print '������������� ���������� ������'
     end
  else
--������������ ��� � ���������� ������ �� ����������� � ������� order_zoo ������
  begin
    select @y=i.id_goods, @x=i.qtu
    from order_zoo o, inserted i
    where o.id_goods=i.id_goods
--� ������������ ��������� ���������� ������ � ������� goods
         update goods
         set quantity=quantity-@x
         where id_goods=@y
    end
end

--------------------------------------
create trigger trigger_discount_card
on order_zoo for insert
as
declare @id_client int, @amount int, @id_goods int
select @id_client=i.id_client, @amount=i.qtu*g.cost
from inserted i, goods g
where g.id_goods=i.id_goods

if @@rowcount=1
--� ������� order_zoo ����������� ������ � ������� ������
--��������� ��� ��������� ������ � ������� client
begin
--���� ������ � ������� ��� ���, ����������� ��������������� ������ � ������� client
if not exists ( select * from client c, inserted i
					where c.id_client=i.id_client )
		begin
		insert into client values (@id_client,'unnamed',0,@amount)
			begin
			if @amount>=10000
			 update client
			 set percentage_card = @amount/10000+2
			 where id_client=@id_client
			end
		 end
else
--���� ����, �� ������������ ��������� ������ � ������� client  
	begin
         update client
         set total_amount=total_amount+@amount, percentage_card = (total_amount+@amount)/10000+2
         where id_client=@id_client
    end
end

--�������� ���������,8 �������� �� ������� ������
INSERT INTO order_zoo VALUES (1,9,1,1,'cash', getdate());
INSERT INTO order_zoo VALUES (1,8,1,3,'cash', getdate());
INSERT INTO order_zoo VALUES (2,1,2,1,'cash', getdate());
INSERT INTO order_zoo VALUES (3,5,3,5,'card', getdate());
INSERT INTO order_zoo VALUES (3,6,3,2,'card', getdate());
INSERT INTO order_zoo VALUES (4,7,4,8,'cash', getdate());
INSERT INTO order_zoo VALUES (5,8,5,6,'card', getdate());
INSERT INTO order_zoo VALUES (6,9,6,10,'card', getdate());



--��������� ������������� adminDB, securDB, readerDB � SQL Server.
execute sp_addlogin @loginame='adminDB', @passwd='test';
execute sp_addlogin @loginame='securDB', @passwd='test';
execute sp_addlogin @loginame='readerDB', @passwd='test'; 
--��������� ���� ������
use assel_zooshop;
--��������� ������������ test_user � �������� ���� ������.
execute sp_grantdbaccess @loginame='adminDB';
execute sp_grantdbaccess @loginame='securDB';
execute sp_grantdbaccess @loginame='readerDB';
--��������� ���� ��������� �������������
execute sp_addrolemember @rolename='db_accessadmin', @membername='adminDB'; 
execute sp_addrolemember @rolename='db_securityadmin', @membername='securDB'; 
execute sp_addrolemember @rolename='db_datareader', @membername='readerDB';




