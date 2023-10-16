-- primeiro exercício
delimiter //

create function total_livros_por_genero(genero varchar(100)) returns int deterministic
begin
    declare quantidade_livros int default 0;
    declare encerrado int default 0;
    declare titulo_livro varchar(255);
    
    declare cursor_livro_categoria cursor for
    select titulo
    from livro
    where id_genero = (select id from genero where nome_genero = genero);
    
    declare continue handler for not found set encerrado = 1;
    
    open cursor_livro_categoria;
    
    lista_livros: loop
        fetch cursor_livro_categoria into titulo_livro;
        if encerrado = 1 then
            leave lista_livros;
        end if;
        
        set quantidade_livros = quantidade_livros + 1;
    end loop;
    
    close cursor_livro_categoria;
    
    return quantidade_livros;
end; //

delimiter ;

select total_livros_por_genero('História') as livros;

-- segundo exercício
delimiter //

create function listar_livros_por_autor(primeiro_nome varchar(255), ultimo_nome varchar(255)) returns text deterministic
begin
    declare lista_de_livros text default '';

    declare encerrado int default 0;
    declare nome_do_titulo varchar(255);

    declare cursor_livro_autor cursor for
    select l.titulo
    from livro_autor as la
    inner join livro as l on la.id_livro = l.id
    inner join autor as a on la.id_autor = a.id
    where a.primeiro_nome = primeiro_nome and a.ultimo_nome = ultimo_nome;

    declare continue handler for not found set encerrado = 1;

    open cursor_livro_autor;

    lista_livros: loop
        fetch cursor_livro_autor into nome_do_titulo;
        if encerrado = 1 then
            leave lista_livros;
        end if;

        set lista_de_livros = concat(lista_de_livros, nome_do_titulo, '\n');
    end loop;

    close cursor_livro_autor;

    return lista_de_livros;
end //

delimiter ;

select listar_livros_por_autor('Maria', 'Fernandes');

-- terceiro exercício
delimiter //

create function atualizar_resumos() returns int deterministic
begin
    declare encerrado int default 0;
    declare livro_id int;
    declare novo_resumo text;
    
    declare cursor_livro_resumo cursor for
    select id, resumo
    from livro;
    
    declare continue handler for not found set encerrado = 1;

    open cursor_livro_resumo;

    atualizar: loop
        fetch cursor_livro_resumo into livro_id, novo_resumo;
        if encerrado = 1 then
            leave atualizar;
        end if;

        set novo_resumo = concat(novo_resumo, ' este é um excelente livro!');
        
        update livro set resumo = novo_resumo where id = livro_id;
    end loop;

    close cursor_livro_resumo;

    return 1;
end //

delimiter ;

select atualizar_resumos();
select resumo from livro;

-- quarto exercício 
delimiter //

create function media_livros_por_editora() returns decimal(10, 2) deterministic
begin
    declare padrao_encerrado int default 0;
    declare quantidade_livros int default 0;
    declare quantidade_editoras int default 0;
    declare media decimal(10,2) default 0.00;
    declare id_editora_atual int;
    declare livros_por_editora int;

    declare cursor_editoras cursor for
    select count(id) from livro where id_editora = id_editora_atual;

    declare cursor_media_editora cursor for
    select id from editora;

    declare continue handler for not found set padrao_encerrado = 1;
    
    open cursor_media_editora;

    calculo_media: loop
        fetch cursor_media_editora into id_editora_atual;

        if padrao_encerrado = 1 then
            leave calculo_media;
        end if;

        open cursor_editoras;
        fetch cursor_editoras into livros_por_editora;
        close cursor_editoras;

        set quantidade_livros = quantidade_livros + livros_por_editora;
        set quantidade_editoras = quantidade_editoras + 1;
    end loop;
    
    if quantidade_editoras > 0 then
        set media = quantidade_livros / quantidade_editoras;
    end if;

    close cursor_media_editora;

    return media;
end; //

delimiter ;

select media_livros_por_editora();

-- quinto exercício
delimiter //

create function autores_sem_livros() returns text deterministic
begin
    declare encerrado int default 0;
    declare autores_sem_livro text default '';

    declare cursor_livro_autor cursor for
    select primeiro_nome as nome_do_autor
    from autor
    where id not in (select distinct id_autor from livro_autor);

    declare continue handler for not found set encerrado = 1;

    open cursor_livro_autor;

    lista_autores: loop
        fetch cursor_livro_autor into autores_sem_livro;
        if encerrado = 1 then
            leave lista_autores;
        end if;

        if autores_sem_livro != '' then
            set autores_sem_livro = concat(autores_sem_livro, ', ', autores_sem_livro);
        end if;
    end loop;

    close cursor_livro_autor;

    return autores_sem_livro;
end; //

delimiter ;

select autores_sem_livros() as autor_sem_livro;
