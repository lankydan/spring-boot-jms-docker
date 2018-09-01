package lankydan.tutorial.jms;

import lankydan.tutorial.documents.OrderTransaction;
import lankydan.tutorial.repositories.OrderTransactionRepository;
import org.springframework.jms.annotation.JmsListener;
import org.springframework.stereotype.Component;

@Component
public class OrderTransactionReceiver {

    private final OrderTransactionRepository transactionRepository;

    private int count = 1;

    public OrderTransactionReceiver(OrderTransactionRepository transactionRepository) {
        this.transactionRepository = transactionRepository;
    }

    @JmsListener(destination = "OrderTransactionQueue", containerFactory = "myFactory")
    public void receiveMessage(OrderTransaction transaction) {
        System.out.println("<" + count + "> Received <" + transaction + ">");
        count++;
        transactionRepository.save(transaction);
    }
}
