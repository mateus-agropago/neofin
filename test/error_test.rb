# frozen_string_literal: true

require "test_helper"

# Testa se as classes de erro existem e herdam corretamente
module Neofin
  class ErrorTest < Minitest::Test
    # Define a classe de teste simples aqui, fora do método de teste específico.
    # Ela ainda estará acessível dentro dos métodos de teste desta classe.
    class MyTestClass
      def do_something_dangerous
        raise Neofin::ClientError, "Something went wrong"
      end
    end

    # Testa se a classe base Error existe e herda de StandardError
    def test_base_error_inheritance
      # 'assert_kind_of' verifica se um objeto é de uma determinada classe ou subclasse.
      # Aqui, criamos uma instância de Neofin::Error e verificamos se é um StandardError.
      assert_kind_of StandardError, Neofin::Error.new("test message")
    end

    # Testa se as classes de erro específicas existem e herdam da classe base Error
    def test_specific_error_inheritance
      # Lista das nossas classes de erro personalizadas
      error_classes = [
        Neofin::ConfigurationError,
        Neofin::AuthenticationError,
        Neofin::NotFoundError,
        Neofin::ClientError,
        Neofin::ServerError
      ]

      # Itera sobre cada classe de erro na lista
      error_classes.each do |error_class|
        # Cria uma instância da classe de erro atual
        error_instance = error_class.new("test message for #{error_class}")
        # Verifica se a instância herda da nossa classe base Neofin::Error
        assert_kind_of Neofin::Error, error_instance, "#{error_class} should inherit from Neofin::Error"
        # Verifica também se herda de StandardError (indiretamente)
        assert_kind_of StandardError, error_instance, "#{error_class} should inherit from StandardError"
      end
    end

    # Testa se podemos lançar e capturar nossos erros personalizados
    def test_raising_and_rescuing_errors
      # Cria uma instância da classe definida acima
      instance = MyTestClass.new

      # 'assert_raises' verifica se um bloco de código lança um erro específico.
      # Ele garante que a exceção ClientError é lançada quando chamamos o método.
      assert_raises(Neofin::ClientError) do
        instance.do_something_dangerous
      end

      # Exemplo de como capturar o erro (não é um teste direto, mas demonstra o uso)
      rescued = false
      begin
        instance.do_something_dangerous
      rescue Neofin::ClientError => e
        # 'assert_equal' verifica se dois valores são iguais.
        assert_equal "Something went wrong", e.message
        rescued = true
      rescue StandardError
        # Falha o teste se outro tipo de erro for capturado
        flunk("Should have rescued Neofin::ClientError, but rescued another StandardError")
      end
      # Garante que o bloco 'rescue Neofin::ClientError' foi executado
      assert rescued, "The Neofin::ClientError should have been rescued"
    end
  end
end
