-- primeiro exercício
create trigger data_hora_trigger after insert on Clientes for each row
    insert into Auditoria(mensagem, data_hora)
    values('Oi, eu sou a Melissa', now());

-- segundo exercício
create trigger excluir_cliente_trigger before delete on Clientes for each row
    insert into Auditoria(mensagem)
    values('Excluindo cliente!!!');

-- terceiro exercício
create trigger atualizar_nome_trigger after update on Clientes for each row
    insert into Auditoria(mensagem)
    values(concat('Antigo: ', old.nome, ', Novo: ', new.nome));

-- quarto exercício
delimiter //

create trigger atualizacao_trigger before update on Clientes for each row
begin
    if new.nome is null or new.nome = '' then
        insert into Auditoria (mensagem)
        values (concat('Falha! Nome do cliente vazio ou nulo.'));
        
        set new.nome = old.nome;
    end if;
end; //

delimiter ;

-- quinto exercício
delimiter //

create trigger estoque_trigger after insert on Pedidos for each row
begin
    update Produtos
    set estoque = estoque - new.quantidade
    where id = new.produto_id;

    if (select estoque from Produtos where id = new.produto_id) < 5 then
        insert into Auditoria (mensagem)
        values('Estoque abaixo de 5 unidades.');
    end if;
end; //

delimiter ;
